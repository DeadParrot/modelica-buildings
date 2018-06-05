within Buildings.Fluid.Storage.Examples;
model StratifiedUnloadAtMinimumTemperature
  "Example that demonstrates how to draw from a hot water tank at the minimum temperature"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  parameter Modelica.SIunits.Volume VTan=3 "Tank volume";

  parameter Modelica.SIunits.MassFlowRate m_flow_nominal = 3*1000/3600
    "Nominal mass flow rate";

  constant Integer nSeg=5 "Number of volume segments";

  Buildings.Fluid.Storage.Stratified tan(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    VTan=VTan,
    hTan=2,
    dIns=0.2,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nSeg=nSeg,
    T_start=353.15) "Hot water storage tank"
    annotation (Placement(transformation(extent={{-120,-130},{-100,-110}})));
  Sources.Boundary_pT loa(
    redeclare package Medium = Medium,
    nPorts=1)
    "Load (imposed by a constant pressure boundary condition and the flow of masSou)"
    annotation (Placement(transformation(extent={{242,-70},{222,-50}})));
  Sources.MassFlowSource_T masSou(
    nPorts=1,
    redeclare package Medium = Medium,
    m_flow=m_flow_nominal) "Mass flow rate into the tank"
    annotation (Placement(transformation(extent={{242,-130},{222,-110}})));

  Actuators.Valves.TwoWayLinear valTop(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=3000,
    use_inputFilter=false) "Control valve at top"
    annotation (Placement(transformation(extent={{112,-30},{132,-10}})));

  Actuators.Valves.TwoWayLinear valMed(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=3000,
    use_inputFilter=false) "Control valve at top"
    annotation (Placement(transformation(extent={{132,-70},{152,-50}})));

  Actuators.Valves.TwoWayLinear valBot(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dpValve_nominal=3000,
    use_inputFilter=false) "Control valve at top"
    annotation (Placement(transformation(extent={{150,-110},{170,-90}})));

  Modelica.Blocks.Sources.Constant TSetLoa(k=273.15 + 40,
    y(unit="K",
      displayUnit="degC")) "Set point for temperature needed by the load"
    annotation (Placement(transformation(extent={{-140,50},{-120,70}})));

  Modelica.Blocks.Sources.Constant TSetHea(
    y(unit="K", displayUnit="degC"),
    k=273.15 + 50) "Set point for temperature needed by the load"
    annotation (Placement(transformation(extent={{-260,-128},{-240,-108}})));

  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor TMid
    "Temperature tank middle"
    annotation (Placement(transformation(extent={{-102,76},{-82,96}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor TBot
    "Temperature tank bottom"
    annotation (Placement(transformation(extent={{-102,36},{-82,56}})));
  Controls.OBC.CDL.Logical.OnOffController onOffBot(bandwidth=0.1)
    "Controller for valve at bottom"
    annotation (Placement(transformation(extent={{-50,30},{-30,50}})));
  Sensors.TemperatureTwoPort senTem(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    tau=0) "Outflowing temperature"
    annotation (Placement(transformation(extent={{190,-70},{210,-50}})));
  Controls.OBC.CDL.Logical.OnOffController onOffMid(bandwidth=0.1)
    "Controller for valve at middle of tank"
    annotation (Placement(transformation(extent={{-50,70},{-30,90}})));
  Controls.OBC.CDL.Logical.And and2
    "And block to compute control action for middle valve"
    annotation (Placement(transformation(extent={{10,70},{30,90}})));
  Controls.OBC.CDL.Conversions.BooleanToReal yMid
    "Boolean to real conversion for valve at middle"
    annotation (Placement(transformation(extent={{80,70},{100,90}})));
  Controls.OBC.CDL.Conversions.BooleanToReal yTop
    "Boolean to real conversion for valve at top"
    annotation (Placement(transformation(extent={{80,110},{100,130}})));
  Controls.OBC.CDL.Logical.Nor nor "Nor block for top-most control valve"
    annotation (Placement(transformation(extent={{50,110},{70,130}})));
  Controls.OBC.CDL.Logical.Not not1
    "Not block to negate control action of upper level control"
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow hea
    "Heat input at the bottom of the tank"
    annotation (Placement(transformation(extent={{-150,-134},{-130,-114}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor TTop
    "Temperature tank top"
    annotation (Placement(transformation(extent={{-160,-100},{-180,-80}})));
  Controls.OBC.CDL.Logical.OnOffController onOffHea(bandwidth=0.1)
    "Controller for heater at bottom"
    annotation (Placement(transformation(extent={{-210,-134},{-190,-114}})));
  Controls.OBC.CDL.Conversions.BooleanToReal yHea(realTrue=150000)
    "Boolean to real for valve at bottom"
    annotation (Placement(transformation(extent={{-180,-134},{-160,-114}})));
  Controls.OBC.CDL.Conversions.BooleanToReal yBot
    "Boolean to real conversion for valve at bottom"
    annotation (Placement(transformation(extent={{80,30},{100,50}})));
equation
  connect(masSou.ports[1], tan.port_b) annotation (Line(points={{222,-120},{-100,
          -120}},             color={0,127,255}));
  connect(TMid.port, tan.heaPorVol[3])
    annotation (Line(points={{-102,86},{-110,86},{-110,-120}},
                                                             color={191,0,0}));
  connect(TBot.port, tan.heaPorVol[5])
    annotation (Line(points={{-102,46},{-110,46},{-110,-120}},
                                                           color={191,0,0}));
  connect(valTop.port_b, senTem.port_a) annotation (Line(points={{132,-20},{182,
          -20},{182,-60},{190,-60}},
                                   color={0,127,255}));
  connect(valMed.port_b, senTem.port_a)
    annotation (Line(points={{152,-60},{190,-60}},
                                                 color={0,127,255}));
  connect(valBot.port_b, senTem.port_a) annotation (Line(points={{170,-100},{182,
          -100},{182,-60},{190,-60}},
                              color={0,127,255}));
  connect(senTem.port_b,loa. ports[1])
    annotation (Line(points={{210,-60},{222,-60}},
                                                 color={0,127,255}));
  connect(valTop.port_a, tan.fluPorVol[1]) annotation (Line(points={{112,-20},{-112.6,
          -20},{-112.6,-120}}, color={0,127,255}));
  connect(valMed.port_a, tan.fluPorVol[3]) annotation (Line(points={{132,-60},{-112.6,
          -60},{-112.6,-120}},color={0,127,255}));
  connect(valBot.port_a, tan.fluPorVol[5]) annotation (Line(points={{150,-100},{
          -112.6,-100},{-112.6,-120}},
                              color={0,127,255}));
  connect(onOffMid.y, and2.u1)
    annotation (Line(points={{-29,80},{8,80}},     color={255,0,255}));
  connect(yMid.u, and2.y)
    annotation (Line(points={{78,80},{31,80}},   color={255,0,255}));
  connect(yTop.u, nor.y)
    annotation (Line(points={{78,120},{71,120}},
                                             color={255,0,255}));
  connect(and2.y, nor.u1) annotation (Line(points={{31,80},{40,80},{40,120},{48,
          120}},
        color={255,0,255}));
  connect(onOffBot.y, nor.u2) annotation (Line(points={{-29,40},{46,40},{46,112},
          {48,112}},color={255,0,255}));
  connect(yTop.y, valTop.y) annotation (Line(points={{101,120},{122,120},{122,-8}},
                               color={0,0,127}));
  connect(yMid.y, valMed.y) annotation (Line(points={{101,80},{142,80},{142,-48}},
                              color={0,0,127}));
  connect(TBot.T, onOffBot.reference)
    annotation (Line(points={{-82,46},{-52,46}},   color={0,0,127}));
  connect(onOffBot.u, TSetLoa.y) annotation (Line(points={{-52,34},{-64,34},{-64,
          60},{-119,60}}, color={0,0,127}));
  connect(not1.u, onOffBot.y) annotation (Line(points={{-22,60},{-26,60},{-26,40},
          {-29,40}},       color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{1,60},{4,60},{4,72},{8,72}},
        color={255,0,255}));
  connect(TSetLoa.y, onOffMid.u) annotation (Line(points={{-119,60},{-64,60},{-64,
          74},{-52,74}},   color={0,0,127}));
  connect(TMid.T, onOffMid.reference)
    annotation (Line(points={{-82,86},{-52,86}},   color={0,0,127}));
  connect(hea.port, tan.heaPorVol[5]) annotation (Line(points={{-130,-124},{-110,
          -124},{-110,-120}}, color={191,0,0}));
  connect(TTop.port, tan.heaPorVol[1]) annotation (Line(points={{-160,-90},{-110,
          -90},{-110,-120}}, color={191,0,0}));
  connect(onOffHea.u, TTop.T) annotation (Line(points={{-212,-130},{-230,-130},{
          -230,-90},{-180,-90}}, color={0,0,127}));
  connect(onOffHea.y, yHea.u)
    annotation (Line(points={{-189,-124},{-182,-124}}, color={255,0,255}));
  connect(hea.Q_flow, yHea.y)
    annotation (Line(points={{-150,-124},{-159,-124}}, color={0,0,127}));
  connect(TSetHea.y, onOffHea.reference)
    annotation (Line(points={{-239,-118},{-212,-118}}, color={0,0,127}));
  connect(onOffBot.y, yBot.u)
    annotation (Line(points={{-29,40},{78,40}}, color={255,0,255}));
  connect(yBot.y, valBot.y)
    annotation (Line(points={{101,40},{160,40},{160,-88}}, color={0,0,127}));
  annotation (Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-300,-140},{260,140}})),
       __Dymola_Commands(file=
          "modelica://Buildings/Resources/Scripts/Dymola/Fluid/Storage/Examples/StratifiedUnloadAtMinimumTemperature.mos"
        "Simulate and plot"),
    experiment(
      StopTime=21600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(info="<html>
<p>
Example for tank model that has three outlets, each with a valve.
The valve at the bottom opens when the temperature in that tank segment
is sufficiently warm to serve the load.
The tank in the middle also opens when its tank temperature is sufficiently high,
but only if the valve below is closed.
Finally, the valve at the top only opens if no other valve is open.
Hence, there is always exactly one valve open.
On the right-hand side of the model is a heater that adds heat to the bottom of the
tank if the top tank segment is below the set point temperature.
</p>
</html>", revisions="<html>
<ul>
<li>
June 1, 2018, by Michael Wetter:<br/>
First implementation.<br/>
This is for <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1182\">
issue 1182</a>.
</li>
</ul>
</html>"));
end StratifiedUnloadAtMinimumTemperature;
