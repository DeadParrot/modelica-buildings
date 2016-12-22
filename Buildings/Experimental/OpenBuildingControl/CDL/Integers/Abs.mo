within Buildings.Experimental.OpenBuildingControl.CDL.Integers;
block Abs "Output the absolute value of the input"
  extends Modelica.Blocks.Icons.IntegerBlock;

  Modelica.Blocks.Interfaces.IntegerInput u "Connector of Integer input signals"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.IntegerOutput y "Connector of Integer output signals"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

equation
  y = if u >= 0 then u else -u;
  annotation (
    defaultComponentName="abs1",
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics={
        Polygon(
          points={{92,0},{70,8},{70,-8},{92,0}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{0,-14},{0,68}}, color={192,192,192}),
        Polygon(
          points={{0,90},{-8,68},{8,68},{0,90}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-34,-28},{38,-76}},
          lineColor={192,192,192},
          textString="abs"),
        Line(points={{-88,0},{76,0}}, color={192,192,192}),
        Ellipse(
          extent={{-68,68},{-60,60}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-38,38},{-30,30}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-4,4},{4,-4}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{28,38},{36,30}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{58,68},{66,60}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{-64,-6},{-64,6}},
                                      color={192,192,192}),
        Line(points={{-34,-6},{-34,6}},
                                      color={192,192,192}),
        Line(points={{32,-6},{32,6}}, color={192,192,192}),
        Line(points={{62,-6},{62,6}}, color={192,192,192}),
        Line(points={{-8,64},{8,64}}, color={192,192,192}),
        Line(points={{-8,34},{8,34}}, color={192,192,192})}),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{
            100,100}})),
    Documentation(info="<html>
<p>
This blocks computes the output <code>y</code>
as <i>absolute value</i> of the input <code>u</code>:
</p>
<pre>
    y = <code>abs</code>( u );
</pre>
<p>
The Boolean parameter generateEvent decides whether Events are generated at zero crossing (Modelica specification before 3) or not.
</p>
</html>"));
end Abs;
