/*
 * @Date: 2021.04.29 14:33
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.29 14:33
 */
import 'dart:io';

var _enable_color = Platform.environment['TERM_COLOR'] != 'disable';
const _unset_color = '\x1b[0m';
const _red = '31';

class Color {
  static const String Black = 'black';
  static const String Red = 'red';
  static const String Green = 'green';
  static const String Yellow = 'yellow';
  static const String Blue = 'blue';
  static const String Magenta = 'magenta';
  static const String Cyan = 'cyan';
  static const String White = 'white';

  static const String LightBlack = 'light_black';
  static const String LightRed = 'light_red';
  static const String LightGreen = 'light_green';
  static const String LightYellow = 'light_yellow';
  static const String LightBlue = 'light_blue';
  static const String LightMagenta = 'light_magenta';
  static const String LightCyan = 'light_cyan';
  static const String LightWhite = 'light_white';

  static const String BgBlack = 'bg_black';
  static const String BgRed = 'bg_red';
  static const String BgGreen = 'bg_green';
  static const String BgYellow = 'bg_yellow';
  static const String BgBlue = 'bg_blue';
  static const String BgMagenta = 'bg_magenta';
  static const String BgCyan = 'bg_cyan';
  static const String BgWhite = 'bg_white';

  static const String LightBgBlack = 'light_bg_black';
  static const String LightBgRed = 'light_bg_red';
  static const String LightBgGreen = 'light_bg_green';
  static const String LightBgYellow = 'light_bg_yellow';
  static const String LightBgBlue = 'light_bg_blue';
  static const String LightBgMagenta = 'light_bg_magenta';
  static const String LightBgCyan = 'light_bg_cyan';
  static const String LightBgWhite = 'light_bg_white';
}

var _color_dict = {
  'black': '30',
  'red': '31',
  'green': '32',
  'yellow': '33',
  'blue': '34',
  'magenta': '35',
  'cyan': '36',
  'white': '37',
  'light_black': '1;30',
  'light_red': '1;31',
  'light_green': '1;32',
  'light_yellow': '1;33',
  'light_blue': '1;34',
  'light_magenta': '1;35',
  'light_cyan': '1;36',
  'light_white': '1;37',
  'bg_black': '40',
  'bg_red': '41',
  'bg_green': '42',
  'bg_yellow': '43',
  'bg_blue': '44',
  'bg_magenta': '45',
  'bg_cyan': '46',
  'bg_white': '47',
  'light_bg_black': '100',
  'light_bg_red': '101',
  'light_bg_green': '102',
  'light_bg_yellow': '103',
  'light_bg_blue': '104',
  'light_bg_magenta': '105',
  'light_bg_cyan': '106',
  'light_bg_white': '107',
};

String convert_color(String color) {
  return _color_dict[color] ?? _red;
}

String set_color(String color) {
  return _enable_color ? '\x1b[${convert_color(color)}m' : '';
}

String unset_color(String msg) {
  return _enable_color ? msg + _unset_color : msg;
}

String scolorf(String color, String msg) {
  return _enable_color ? '\x1b[${convert_color(color)}m$msg\x1b[0m' : msg;
}

void colorln(String color, String msg) {
  print(scolorf(color, msg));
}

String sredf(String msg) {
  return scolorf(Color.Red, msg);
}

void redln(String msg) {
  colorln(Color.Red, msg);
}

String sgreenf(String msg) {
  return scolorf(Color.Green, msg);
}

void greenln(String msg) {
  colorln(Color.Green, msg);
}

String syellowf(String msg) {
  return scolorf(Color.Yellow, msg);
}

void yellowln(String msg) {
  colorln(Color.Yellow, msg);
}

String sbluef(String msg) {
  return scolorf(Color.Blue, msg);
}

void blueln(String msg) {
  colorln(Color.Blue, msg);
}

String smagentaf(String msg) {
  return scolorf(Color.Magenta, msg);
}

void magentaln(String msg) {
  colorln(Color.Magenta, msg);
}

String scyanf(String msg) {
  return scolorf(Color.Cyan, msg);
}

void cyanln(String msg) {
  colorln(Color.Cyan, msg);
}

void main(List<String> arguments) {
  redln('Love life, enjoy life.');
  greenln('Love life, enjoy life.');
  yellowln('Love life, enjoy life.');
  blueln('Love life, enjoy life.');
  magentaln('Love life, enjoy life.');
  cyanln('Love life, enjoy life.');
}
