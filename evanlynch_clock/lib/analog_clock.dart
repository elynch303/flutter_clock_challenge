// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';


enum _Element {
  background, text, shadow, hour, minute, second,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.redAccent,
  _Element.shadow: Colors.black45,
  _Element.hour: Colors.pinkAccent,
  _Element.minute: Colors.cyanAccent,
  _Element.second: Colors.orangeAccent,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.red,
  _Element.shadow: Colors.white54,
  _Element.hour: Colors.pink,
  _Element.minute: Colors.cyan,
  _Element.second: Colors.orange,
};

_getWetherImage(condition){
  switch(condition){
    case "cloudy":{
      return Image.asset("assets/img/weather/cloudy.png");
    }break;
    case "foggy":{
      return Image.asset("assets/img/weather/foggy.png");
    }break;
    case "rainy":{
      return Image.asset("assets/img/weather/rainy.png");
    }break;
    case "snowy":{
      return Image.asset("assets/img/weather/snowy.png");
    }break;
    case "sunny":{
      return Image.asset("assets/img/weather/sunny.png");
    }break;
    case "thunder":{
      return Image.asset("assets/img/weather/thunder.png");
    }break;
    case "windy":{
      return Image.asset("assets/img/weather/windy.png");
    }break;
  }
}

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
     widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _pulse() {
    if(opacity == 0.0){opacity = 1;}
    else{ opacity = 0.0;}
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime _dateTime = DateTime.now();
    final time = DateFormat.Hms().format(_dateTime);
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final secPercent = 100 / 60 * _now.second / 100;
    final minPercent = 100 / 60 * _now.minute / 100;
    final hourPercent = widget.model.is24HourFormat ? 100 / 24 * _now.hour / 100 : 100 / 12 * ( _now.hour - 12 ) / 100;
    final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
    final fontSize = MediaQuery.of(context).size.width / 25;
    shadow(br, odx, ody, color){
      return  Shadow(
        blurRadius: br,
        color: color,
        offset: Offset(odx, ody),
      );
    }
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Monoton',
      fontSize: fontSize,
      shadows: [shadow(0,5,0, colors[_Element.shadow])],
    );
    final dividerStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Tomorrow',
      fontSize: fontSize,
      shadows: [shadow(0,10,0, colors[_Element.shadow])],
    );
    final infoStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Tomorrow',
      fontSize: MediaQuery.of(context).size.width / 40,
      shadows: [shadow(0,2,0, Colors.black)],
    );
    final clock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DefaultTextStyle(style: defaultStyle, child: Text(hour)),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: opacity,
          child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, fontSize / 4), child: DefaultTextStyle(style: dividerStyle, child: Text(":"))), 
        ),
        DefaultTextStyle(style: defaultStyle, child: Text(minute)),
      ],
    );
    final weatherInfo = DefaultTextStyle(
      style: infoStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
               _getWetherImage(_condition),
              Column(
                children: [
                  Text(_temperature),
                  Text(_temperatureRange),
                ]
              ),
            ],
          ),
          Text(_location),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: colors[_Element.background],
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.center,
          children: [
            CircularPercentIndicator(
              radius: MediaQuery.of(context).size.width / 2.5,
              lineWidth: MediaQuery.of(context).size.width / 40,
              percent: hourPercent,
              backgroundColor: colors[_Element.background],
              progressColor: colors[_Element.hour],
              center:
                CircularPercentIndicator(
                  radius: MediaQuery.of(context).size.width / 3,
                  lineWidth: MediaQuery.of(context).size.width / 50,
                  percent: minPercent,
                  backgroundColor: colors[_Element.background],
                  progressColor: colors[_Element.minute],
                  center:
                    CircularPercentIndicator(
                      radius: MediaQuery.of(context).size.width / 3.75,
                      lineWidth: MediaQuery.of(context).size.width / 50,
                      percent: secPercent,
                      center: DefaultTextStyle(
                        style: defaultStyle,
                        child: clock
                      ),
                      backgroundColor: colors[_Element.background],
                      progressColor: colors[_Element.second],
                    ),
                ),
              ),
            Positioned(
              left: 0,
              top: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: weatherInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
