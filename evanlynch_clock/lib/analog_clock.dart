// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

enum _Element {
  background,
  text,
  infoText,
  infoShadow,
  shadow,
  hour,
  minute,
  second,
}

final _lightTheme = {
  _Element.background: Colors.blue,
  _Element.text: Colors.white,
  _Element.infoText: Colors.white70,
  _Element.shadow: Colors.black38,
  _Element.infoShadow: Colors.black38,
  _Element.hour: Colors.pink,
  _Element.minute: Colors.green,
  _Element.second: Colors.orange,
};

final _darkTheme = {
  _Element.background: Colors.black45,
  _Element.text: Colors.yellow,
  _Element.infoText: Colors.yellowAccent,
  _Element.shadow: Colors.white,
  _Element.infoShadow: Colors.white,
  _Element.hour: Colors.pinkAccent,
  _Element.minute: Colors.greenAccent,
  _Element.second: Colors.orangeAccent,
};

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
  var _timeOfDay = "day";
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

  _getWetherImage(condition) {
    if (condition == null) {
      return Image.asset("assets/img/weather/na.png");
    }
    return Image.asset(
        "assets/img/weather/" + _timeOfDay + "_" + condition + ".png");
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
    if (opacity == 0.0) {
      opacity = 1;
    } else {
      opacity = 0.0;
    }
  }

  _getTimePercent(fullLevel, now) {
    if(now == -12){
      now = 0;
    }
    return 100 / fullLevel * now / 100;
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
      _pulse();
       if (_now.hour > 18 || _now.hour < 6) {
        _timeOfDay = "night";
      }else{
        _timeOfDay = "day";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime _dateTime = DateTime.now();
    final time = DateFormat.Hms().format(_dateTime);
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final secPercent = _getTimePercent(60, _now.second);
    final minPercent = _getTimePercent(60, _now.minute);
    final hourPercent = widget.model.is24HourFormat
        ? _getTimePercent(24, _now.hour)
        : _getTimePercent(12, (_now.hour - 12));
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final fontSize = MediaQuery.of(context).size.width / 20;
    shadow(br, odx, ody, color) {
      return Shadow(
        blurRadius: br,
        color: color,
        offset: Offset(odx, ody),
      );
    }

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Audiowide',
      fontSize: fontSize,
      shadows: [shadow(0.0, 4.0, 0.0, colors[_Element.shadow])],
    );
    final secStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Audiowide',
      fontSize: fontSize / 2,
      shadows: [shadow(0.0, 3.0, 0.0, colors[_Element.shadow])],
    );
    final infoStyle = TextStyle(
      color: colors[_Element.infoText],
      fontFamily: 'Exo2',
      fontSize: MediaQuery.of(context).size.width / 50,
      shadows: [shadow(0.0, 2.0, 0.0, colors[_Element.infoShadow])],
    );
    final clock = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  DefaultTextStyle(style: defaultStyle, child: Text(hour)),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: opacity,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 5, fontSize / 6),
                        child: DefaultTextStyle(
                            style: defaultStyle, child: Text(":"))),
                  ),
                  DefaultTextStyle(style: defaultStyle, child: Text(minute)),
                ],
              ),
              DefaultTextStyle(style: secStyle, child: Text(second)),
            ],
          )
        ]);
    final weatherInfo = DefaultTextStyle(
      style: infoStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_location),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: _getWetherImage(_condition),
              ),
              Column(children: [
                Text(_temperature),
                Text(_temperatureRange),
              ]),
            ],
          ),
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
              backgroundColor: Colors.transparent,
              progressColor: colors[_Element.hour],
              center: CircularPercentIndicator(
                radius: MediaQuery.of(context).size.width / 3,
                lineWidth: MediaQuery.of(context).size.width / 50,
                percent: minPercent,
                backgroundColor: Colors.transparent,
                progressColor: colors[_Element.minute],
                center: CircularPercentIndicator(
                  radius: MediaQuery.of(context).size.width / 3.75,
                  lineWidth: MediaQuery.of(context).size.width / 55,
                  percent: secPercent,
                  center: DefaultTextStyle(style: defaultStyle, child: clock),
                  backgroundColor: Colors.transparent,
                  progressColor: colors[_Element.second],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
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
