within Buildings.Controls.OBC.ASHRAE.G36.Atomic;
block OutdoorAirFlowSetpoint_SingleZone
  "Output the minimum outdoor airflow rate setpoint for systems with a single zone"

  parameter Real outAirPerAre(final unit="m3/(s.m2)") = 3e-4
    "Outdoor air rate per unit area"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.VolumeFlowRate outAirPerPer = 2.5e-3
    "Outdoor air rate per person"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Area zonAre
    "Area of each zone"
    annotation(Dialog(group="Nominal condition"));
  parameter Boolean occSen = true
    "Set to true if zones have occupancy sensor";
  parameter Real occDen(final unit="1/m2") = 0.05
    "Default number of person in unit area";
  parameter Real zonDisEffHea(final unit="1") = 0.8
    "Zone air distribution effectiveness during heating";
  parameter Real zonDisEffCoo(final unit="1") = 1.0
    "Zone air distribution effectiveness during cooling";
  parameter Real uLow(final unit="K",
    quantity="ThermodynamicTemperature") = -0.5
    "If zone space temperature minus supply air temperature is less than uLow, 
     then it should use heating supply air distribution effectiveness"
    annotation (Dialog(tab="Advanced"));
  parameter Real uHig(final unit="K",
    quantity="ThermodynamicTemperature") = 0.5
    "If zone space temperature minus supply air temperature is more than uHig, 
     then it should use cooling supply air distribution effectiveness"
    annotation (Dialog(tab="Advanced"));

  CDL.Interfaces.RealInput nOcc(final unit="1") "Number of occupants"
    annotation (Placement(transformation(extent={{-240,140},{-200,180}}),
        iconTransformation(extent={{-240,140},{-200,180}})));
  CDL.Interfaces.RealInput TZon(
    final unit="K",
    quantity="ThermodynamicTemperature")  "Measured zone air temperature"
    annotation (Placement(transformation(extent={{-240,-60},{-200,-20}}),
      iconTransformation(extent={{-240,80},{-200,120}})));
  CDL.Interfaces.RealInput TSup(
    final unit="K",
    quantity="ThermodynamicTemperature")   "Supply air temperature"
    annotation (Placement(transformation(extent={{-240,-100},{-200,-60}}),
      iconTransformation(extent={{-240,20},{-200,60}})));
  CDL.Interfaces.BooleanInput uSupFan
    "Supply fan status, true if on, false if off"
    annotation (Placement(transformation(extent={{-240,-180},{-200,-140}}),
      iconTransformation(extent={{-240,-180},{-200,-140}})));
  CDL.Interfaces.BooleanInput uWin
    "Window status, true if open, false if closed" annotation (Placement(
        transformation(extent={{-240,-10},{-200,30}}), iconTransformation(
          extent={{-240,-100},{-200,-60}})));
  CDL.Interfaces.RealOutput VOutMinSet_flow(
    min=0,
    final unit="m3/s",
    quantity="VolumeFlowRate")   "Effective minimum outdoor airflow setpoint"
    annotation (Placement(transformation(extent={{200,-20},{240,20}}),
      iconTransformation(extent={{200,-20},{240,20}})));

  CDL.Continuous.Add breZon "Breathing zone airflow"
    annotation (Placement(transformation(extent={{-20,70},{0,90}})));
  CDL.Continuous.Add add2(final k1=+1, final k2=-1)
    "Zone space temperature minus supply air temperature"
    annotation (Placement(transformation(extent={{-160,-70},{-140,-50}})));
  CDL.Continuous.Gain gai(final k=outAirPerPer)
    "Outdoor airflow rate per person"
    annotation (Placement(transformation(extent={{-160,150},{-140,170}})));
  CDL.Logical.Switch swi
    "Switch for enabling occupancy sensor input"
    annotation (Placement(transformation(extent={{-60,38},{-40,58}})));
  CDL.Logical.Switch swi1
    "Switch between cooling or heating distribution effectiveness"
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
  CDL.Continuous.Division zonOutAirRate
    "Required zone outdoor airflow rate"
    annotation (Placement(transformation(extent={{20,20},{40,40}})));
  CDL.Logical.Switch swi2
    "If window is open or it is not in occupied mode, the required outdoor 
    airflow rate should be zero"
    annotation (Placement(transformation(extent={{80,20},{100,0}})));
  CDL.Logical.Switch swi3
    "If supply fan is off, then outdoor airflow rate should be zero."
    annotation (Placement(transformation(extent={{140,-10},{160,10}})));
  CDL.Logical.Hysteresis hys(
    uLow=uLow,
    uHigh=uHig,
    pre_y_start=true)
    "Check if cooling or heating air distribution effectiveness should be applied, with 1 degC deadband"
    annotation (Placement(transformation(extent={{-100,-70},{-80,-50}})));

protected
  CDL.Logical.Sources.Constant occSenor(final k=occSen)
    "Boolean constant to indicate if there is occupancy sensor"
    annotation (Placement(transformation(extent={{-160,40},{-140,60}})));
  CDL.Continuous.Sources.Constant zerOutAir(final k=0)
    "Zero required outdoor airflow rate when window open or zone is not in occupied mode"
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
  CDL.Continuous.Sources.Constant disEffHea(final k=zonDisEffHea)
    "Zone distribution effectiveness during heating"
    annotation (Placement(transformation(extent={{-100,-100},{-80,-80}})));
  CDL.Continuous.Sources.Constant disEffCoo(final k=zonDisEffCoo)
    "Zone distribution effectiveness for cooling"
    annotation (Placement(transformation(extent={{-100,-30},{-80,-10}})));
  CDL.Continuous.Sources.Constant breZonAre(final k=outAirPerAre*zonAre)
    "Area component of the breathing zone outdoor airflow"
    annotation (Placement(transformation(extent={{-60,90},{-40,110}})));
  CDL.Continuous.Sources.Constant breZonPop(final k=outAirPerPer*zonAre*occDen)
    "Population component of the breathing zone outdoor airflow"
    annotation (Placement(transformation(extent={{-100,20},{-80,40}})));

equation
  connect(breZonAre.y, breZon.u1)
    annotation (Line(points={{-39,100},{-30,100},{-30,86},{-22,86}},
      color={0,0,127}));
  connect(gai.y, swi.u1)
    annotation (Line(points={{-139,160},{-70,160},{-70,56},{-62,56}},
      color={0,0,127}));
  connect(breZonPop.y, swi.u3)
    annotation (Line(points={{-79,30},{-70,30},{-70,40},{-62,40}},
      color={0,0,127}));
  connect(swi.y, breZon.u2)
    annotation (Line(points={{-39,48},{-30,48},{-30,74},{-22,74}},
      color={0,0,127}));
  connect(disEffCoo.y, swi1.u1)
    annotation (Line(points={{-79,-20},{-60,-20},{-60,-52},{-42,-52}},
      color={0,0,127}));
  connect(disEffHea.y, swi1.u3)
    annotation (Line(points={{-79,-90},{-60,-90},{-60,-68},{-42,-68}},
      color={0,0,127}));
  connect(breZon.y, zonOutAirRate.u1)
    annotation (Line(points={{1,80},{10,80},{10,36},{18,36}},
      color={0,0,127}));
  connect(swi1.y, zonOutAirRate.u2)
    annotation (Line(points={{-19,-60},{10,-60},{10,24},{18,24}},
      color={0,0,127}));
  connect(uWin, swi2.u2)
    annotation (Line(points={{-220,10},{-190,10},{78,10}}, color={255,0,255}));
  connect(zerOutAir.y, swi2.u1)
    annotation (Line(points={{41,-30},{60,-30},{60,2},{78,2}},
      color={0,0,127}));
  connect(zonOutAirRate.y, swi2.u3)
    annotation (Line(points={{41,30},{60,30},{60,18},{78,18}},
      color={0,0,127}));
  connect(swi.u2, occSenor.y)
    annotation (Line(points={{-62,48},{-76,48},{-76,50},{-139,50}},
      color={255,0,255}));
  connect(nOcc, gai.u)
    annotation (Line(points={{-220,160},{-162,160}}, color={0,0,127}));
  connect(swi3.y, VOutMinSet_flow)
    annotation (Line(points={{161,0},{220,0}},   color={0,0,127}));
  connect(zerOutAir.y, swi3.u3)
    annotation (Line(points={{41,-30},{128,-30},{128,-8},{138,-8}},
      color={0,0,127}));
  connect(swi2.y, swi3.u1)
    annotation (Line(points={{101,10},{108,10},{108,8},{138,8}},
      color={0,0,127}));
  connect(uSupFan, swi3.u2)
    annotation (Line(points={{-220,-160},{120,-160},{120,0},{138,0}},
      color={255,0,255}));
  connect(TZon, add2.u1)
    annotation (Line(points={{-220,-40},{-200,-40},{-180,-40},{-180,-54},
      {-162,-54}}, color={0,0,127}));
  connect(TSup, add2.u2)
    annotation (Line(points={{-220,-80},{-180,-80},{-180,-66}, {-162,-66}},
      color={0,0,127}));
  connect(add2.y, hys.u)
    annotation (Line(points={{-139,-60},{-102,-60},{-102,-60}},
        color={0,0,127}));
  connect(hys.y, swi1.u2)
    annotation (Line(points={{-79,-60},{-42,-60},{-42,-60}},
        color={255,0,255}));
 annotation (
defaultComponentName="OutAirSetPoi_SinZon",
Icon(coordinateSystem(
        preserveAspectRatio=false,
        extent={{-200,-200},{200,200}},
        initialScale=0.05),
     graphics={Rectangle(
          extent={{-200,200},{200,-200}},
          lineColor={0,0,0},
          fillColor={210,210,210},
          fillPattern=FillPattern.Solid), Text(
          extent={{-142,116},{146,-96}},
          lineColor={0,0,0},
          textString="minOATsp"),
        Text(
          extent={{-198,250},{200,206}},
          lineColor={0,0,255},
          textString="%name")}),
        Diagram(
        coordinateSystem(preserveAspectRatio=false,
        extent={{-200,-200},{200,200}},
        initialScale=0.05)),
 Documentation(info="<html>      
<p>
This atomic sequence sets the minimum outdoor airflow setpoint for compliance 
with the ventilation rate procedure of ASHRAE 62.1-2013. The implementation 
is according to ASHRAE Guidline 36 (G36), PART5.P.4.b, PART5.B.2.b, PART3.1-D.2.a.
</p>   

<h4>Step 1: Minimum breathing zone outdoor airflow required <code>breZon</code></h4>
<ul>
<li>The area component of the breathing zone outdoor airflow: 
<code>breZonAre = zonAre*outAirPerAre</code>.
</li>
<li>The population component of the breathing zone outdoor airflow: 
<code>breZonPop = occCou*outAirPerPer</code>.
</li>
</ul>
<p>
The number of occupant <code>occCou</code> could be retrieved 
directly from occupancy sensor <code>nOcc</code> if the sensor exists 
(<code>occSen=true</code>), or using the default occupant density 
<code>occDen</code> to find it <code>zonAre*occDen</code>. The occupant 
density can be found from Table 6.2.2.1 in ASHRAE Standard 62.1-2013.
For design purpose, use design zone population <code>desZonPop</code> to find
out the minimum requirement at the ventilation-design condition.
</p>

<h4>Step 2: Zone air-distribution effectiveness <code>zonDisEff</code></h4>
<p>
Table 6.2.2.2 in ASHRAE 62.1-2013 lists some typical values for setting the 
effectiveness. Depending on difference between zone space temperature 
<code>TZon</code> and supply air temperature <code>TSup</code>, Warm-air 
effectiveness <code>zonDisEffHea</code> or Cool-air effectiveness 
<code>zonDisEffCoo</code> should be applied.
</p>

<h4>Step 3: Minimum required zone outdoor airflow <code>zonOutAirRate</code></h4>
<p>
For each zone in any mode other than occupied mode and for zones that have 
window switches and the window is open, <code>zonOutAirRate</code> shall be 
zero.
Otherwise, the required zone outdoor airflow <code>zonOutAirRate</code> 
shall be calculated as follows:
</p>
<i>If the zone is populated, or if there is no occupancy sensor:</i>
<ul>
<li>If discharge air temperature at the terminal unit is less than or equal to 
zone space temperature: <code>zonOutAirRate = (breZonAre+breZonPop)/disEffCoo</code>.
</li>
<li>
If discharge air temperature at the terminal unit is greater than zone space 
temperature: <code>zonOutAirRate = (breZonAre+breZonPop)/disEffHea</code>
</li>
</ul>
<i>If the zone has an occupancy sensor and is unpopulated:</i>
<ul>
<li>If discharge air temperature at the terminal unit is less than or equal to 
zone space temperature: <code>zonOutAirRate = breZonAre/disEffCoo</code></li>
<li>If discharge air temperature at the terminal unit is greater than zone 
space temperature: <code>zonOutAirRate = breZonAre/disEffHea</code></li>
</ul>

<p>
For the single zone system, the required minimum outdoor airflow setpoint 
<code>VOutMinSet_flow</code> equals to the <code>zonOutAirRate</code>.

<h4>References</h4>
<p>
<a href=\"http://gpc36.savemyenergy.com/public-files/\">BSR (ANSI Board of 
Standards Review)/ASHRAE Guideline 36P, 
<i>High Performance Sequences of Operation for HVAC systems</i>. 
First Public Review Draft (June 2016)</a>
</p>
</html>", revisions="<html>
<ul>
<li>
July 6, 2017, by Jianjun Hu:<br/>
Replaced <code>cooCtrlSig</code> input with <code>TZon</code> and <code>TSup</code>
inputs to check if cool or warm air distribution effectiveness should be applied.
Applied hysteresis to avoid rapid change.
</li>
<li>
May 12, 2017, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end OutdoorAirFlowSetpoint_SingleZone;
