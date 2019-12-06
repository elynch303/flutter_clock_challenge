// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.redAccent,
  _Element.shadow: Colors.black45,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.redAccent,
  _Element.shadow: Colors.white54,
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
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
      // Cause the clock to rebuild when the model changes.
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
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _pulse();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light ? _lightTheme : _darkTheme;
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4;
    final offset = -fontSize / 90;
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
      shadows: [shadow(0,10,0, colors[_Element.shadow])],
    );
    final dividerStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Tomorrow',
      fontSize: fontSize,
      shadows: [shadow(0,10,0, colors[_Element.shadow])],
    );
    final infoStyle = TextStyle(
      color: Colors.redAccent,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          _getWetherImage(_condition),
          Text(_location),
        ],
      ),
    );
    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              Container(alignment: Alignment.center, child: clock),
              Positioned(left: 0, bottom: 0, child: Padding(padding: const EdgeInsets.all(8),child: weatherInfo),
            ),
            ],
          ),
        ),
      ),
    );
  }
}


