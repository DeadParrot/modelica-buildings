/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  2/14/2018
 */

#include "FMUEnergyPlusStructure.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Create the structure and return a pointer to its address. */
FMUBuilding* instantiateEnergyPlusFMU(const char* fmuName, const char* zoneName, FMUZone* zone)
{
  char msg[1000];

  /* Allocate memory */
  if (Buildings_nFMU == 0){
    Buildings_FMUS = malloc(sizeof(struct FMUBuilding*));
    if ( Buildings_FMUS == NULL )
      ModelicaError("Not enough memory in FMUZoneInit.c. to allocate array for Buildings_FMU.");
  }
  else{
    Buildings_FMUS = realloc(Buildings_FMUS, (Buildings_nFMU+1) * sizeof(struct FMUBuilding*));
  }

  Buildings_FMUS[Buildings_nFMU] = malloc(sizeof(FMUBuilding));
  if ( Buildings_FMUS[Buildings_nFMU] == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate array for Buildings_FMU[0].");
  Buildings_FMUS[Buildings_nFMU]->zoneNames = malloc(sizeof(char*));
  if ( Buildings_FMUS[Buildings_nFMU]->zoneNames == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate array for Buildings_FMUS[0]->zoneNames.");

  /* Assign the fmu name */
  Buildings_FMUS[Buildings_nFMU]->name = (char*) malloc(strlen(fmuName) * sizeof(char));
  if ( Buildings_FMUS[Buildings_nFMU]->name == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate fmu name.");
  strcpy(Buildings_FMUS[Buildings_nFMU]->name, fmuName);

  /* Assign the zone name */
  Buildings_FMUS[Buildings_nFMU]->zoneNames[0] = malloc(strlen(zoneName) * sizeof(char));
  if ( Buildings_FMUS[Buildings_nFMU]->zoneNames[0] == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone name.");
  strcpy(Buildings_FMUS[Buildings_nFMU]->zoneNames[0], zoneName);

  Buildings_FMUS[Buildings_nFMU]->nZon = 1;

  Buildings_FMUS[Buildings_nFMU]->zones=malloc(sizeof(FMUZone *));
  if ( Buildings_FMUS[Buildings_nFMU]->zones== NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zones.");

  /* Assign the zone */
  Buildings_FMUS[Buildings_nFMU]->zones[0] = zone;

  Buildings_nFMU++;
  /* Return the pointer to the FMU for this EnergyPlus instance */
  return Buildings_FMUS[Buildings_nFMU-1];
};

int zoneIsUnique(const struct FMUBuilding* fmuBld, const char* zoneName){
  int iZ;
  int isUnique = 1;
  for(iZ = 0; iZ < fmuBld->nZon; iZ++){
    if (!strcmp(zoneName, fmuBld->zoneNames[iZ])){
      isUnique = 0;
      break;
    }
  }
  return isUnique;
}

/* Create the structure and return a pointer to its address. */
/*void* FMUZoneInit(const char* fmuName, const char* zoneName, int nFluPor)*/
void* FMUZoneInit(const char* fmuName, const char* zoneName, int nFluPor,
  const char** varNamSen, size_t nVarSen, const char** varNamRec, size_t nVarRec, int* valRefVarRec, size_t nValRefVarRec)
{
  /* Note: The fmuName is needed to unpack the fmu so that the valueReference
     for the zone with zoneName can be obtained */
  char msg[1000];
  unsigned int i;

  ModelicaFormatMessage("****** Initializing zone %s, fmu = %s, nFluPor = %d ****** \n", zoneName, fmuName, nFluPor);

  /* ********************************************************************** */
  /* Initialize the zone */
  FMUZone* zone = (FMUZone*) malloc(sizeof(FMUZone));
  if ( zone == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone.");
  zone->valueReference = NULL;

  zone->valueReference = malloc(nFluPor * sizeof(unsigned int));
  if ( zone->valueReference == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate valueReference.");
  zone->nValueReference = nFluPor; /* Will need to be fixed later */

  /* Assign the value reference. This should be done by using the values from modelDescription.xml */
  for(i = 0; i < nFluPor; i++){
    zone->valueReference[i] = i;
  }

  /* Assign the zone name */
  zone->name = malloc(strlen(zoneName) * sizeof(char));
  if ( zone->name == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone name.");
  strcpy(zone->name, zoneName);

  /* ********************************************************************** */
  /* Initialize the pointer for the FMU to which this zone belongs */
  /* Check if there are any zones */
  if (Buildings_nFMU == 0){
    /* No FMUs exist. Instantiate an FMU and */
    /* assign this fmu pointer to the zone that will invoke its setXXX and getXXX */
    zone->ptrBui = instantiateEnergyPlusFMU(fmuName, zoneName, zone);
  } else {
    /* There is already a Buildings FMU allocated.
       Check if the current zone is for this FMU. */
      zone->ptrBui = NULL;
      for(i = 0; i < Buildings_nFMU; i++){

        if (strcmp(fmuName, Buildings_FMUS[i]->name) == 0){
          /* This is the same FMU as before. */
          if (! zoneIsUnique(Buildings_FMUS[i], zoneName)){
            snprintf(msg, 1000, "Modelica model specifies zone %s twice for the FMU %s. Each zone must only be specified once.",
            zoneName, Buildings_FMUS[i]->name);
            ModelicaError(msg);
          }

          struct FMUBuilding* bld = Buildings_FMUS[i];
          zone->ptrBui = bld;
          /* Increment size of vector that contains the zone names. */
          bld->zoneNames = realloc(bld->zoneNames, (bld->nZon + 1) * sizeof(char*));
          bld->zones = realloc(bld->zones, (bld->nZon + 1) * sizeof(FMUZone*));
          if (bld->zoneNames == NULL){
            ModelicaError("Not enough memory in FMUZoneInit.c. to allocate memory for bld->zoneNames.");
          }
          /* Add storage for new zone name, and copy the zone name */
          bld->zoneNames[bld->nZon] = malloc(strlen(zoneName) * sizeof(char));
          bld->zones[bld->nZon] = zone;
          if ( bld->zoneNames[bld->nZon] == NULL )
            ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone name.");
          strcpy(bld->zoneNames[bld->nZon], zoneName);
          /* Increment the count of zones to this building. */
          bld->nZon++;
          break;
        }
      }
      /* Check if we found an FMU */
      if (zone->ptrBui == NULL){
        /* Did not find an FMU. */
        zone->ptrBui = instantiateEnergyPlusFMU(fmuName, zoneName, zone);
      }
  }
  /* Return a pointer to this zone */
  return (void*) zone;
};
