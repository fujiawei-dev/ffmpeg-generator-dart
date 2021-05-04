/*
 * @Date: 2021.04.29 16:55
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.29 16:55
 */

import 'package:ffmpeg_generator_dart/_ffmpeg.dart';

const input_file = '/path/to/input_file';

void main() {
  input(input_file, kwargs: {})
      .filter('flip', [], {})
      .output(
        ['output_file'],
        vn: true,
        start_position: 0,
        duration: 20,
        args: [],
        kwargs: {
          'stream_loop': 2,
        },
      )
      .compile();
}
