/*
 * @Date: 2021.04.29 16:51
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.29 16:51
 */

import 'constants.dart';
import 'nodes.dart';
import '_node.dart';
import 'settings.dart';
import 'package:path/path.dart' as path;

FilterableStream input(
  String source, {
  String format = '',
  String pixel_format = '',
  int fps = 0,
  double start_position = 0,
  double duration = 0,
  double to_position = 0,
  int stream_loop = 0,
  int frame_rate = 0,
  String hwaccel = '',
  String vcodec = '',
  bool enable_cuda = true,
  required Map<String, dynamic> kwargs,
}) {
  kwargs['source'] = source;

  if (CUDA_ENABLE && enable_cuda && !IMAGE_FORMATS.contains(path.extension(source))) {
    kwargs['hwaccel'] = 'cuda';
    kwargs['vcodec'] = DEFAULT_DECODER;
  }

  if (hwaccel != '') {
    kwargs['hwaccel'] = hwaccel;
  }
  if (vcodec != '') {
    kwargs['vcodec'] = vcodec;
  }
  if (format != '') {
    kwargs['f'] = format;
  }
  if (pixel_format != '') {
    kwargs['pix_fmt'] = pixel_format;
  }
  if (start_position != 0) {
    kwargs['ss'] = start_position;
  }
  if (duration != 0) {
    kwargs['t'] = duration;
  }
  if (to_position != 0) {
    kwargs['to'] = to_position;
  }
  if (stream_loop != 0) {
    kwargs['stream_loop'] = stream_loop;
  }
  if (fps != 0) {
    kwargs['r'] = fps;
  }
  if (frame_rate != 0) {
    kwargs['framerate'] = frame_rate;
  }

  return InputNode(args: [], kwargs: kwargs).stream();
}

FilterableStream merge_outputs(List<Stream> streams) {
  return MergeOutputsNode(streams).stream();
}
