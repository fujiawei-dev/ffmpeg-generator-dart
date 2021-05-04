/*
 * @Date: 2021.04.29 14:33
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.29 14:33
 */

const BACKSLASH = '\\';
var _filter_symbols = {'-filter_complex', '-vf', '-af', '-lavfi'};

String join_cmd_args_seq(List<String> args) {
  var cmd_args_seq = List.from(args);

  for (var i = 0; i < cmd_args_seq.length; i++) {
    if (_filter_symbols.contains(cmd_args_seq[i])) {
      cmd_args_seq[i + 1] = '"${cmd_args_seq[i + 1]}"';
      break;
    }
  }

  return cmd_args_seq.join(' ');
}

List<String> convert_kwargs_to_cmd_line_args(Map<String, dynamic> kwargs, {bool sort = true}) {
  var args = <String>[];
  var keys = <String>[];

  if (sort) {
    keys = kwargs.keys.toList()..sort();
  } else {
    keys = kwargs.keys.toList();
  }

  keys.forEach((key) {
    var v = kwargs[key];
    if (v is List) {
      v.forEach((value) {
        args.add('-$key');
        if (value != '') {
          args.add('$value');
        }
      });
    } else {
      args.add('-$key');
      if (v != '') {
        args.add('$v');
      }
    }
  });

  return args;
}

String escape(String text, String chars) {
  var _chars = Set.from(chars.split('')).toList();

  if (_chars.contains(BACKSLASH)) {
    _chars.remove(BACKSLASH);
    _chars.insert(0, BACKSLASH);
  }

  _chars.forEach((char) {
    text = text.replaceAll(char, BACKSLASH + char);
  });

  return text;
}
