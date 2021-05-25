/*
 * @Date: 2021.04.29 16:55
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.05.25 16:20:26
 */
import 'package:ffmpeg_generator_dart/_ffmpeg.dart';

const input_file = 'C:/Users/Admin/Videos/FFmpeg/InputsData/v1.mp4';
const output_file = 'C:/Users/Admin/Videos/FFmpeg/OutputsData/v1_output.mp4';

Future<void> main() async {
  await input(input_file, kwargs: {})
      .filter('vflip', [], {})
      .output(
        [output_file],
        start_position: 0,
        duration: 20,
        args: [],
        kwargs: {},
      )
      .run();
}
