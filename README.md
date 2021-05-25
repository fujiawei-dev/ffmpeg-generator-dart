<!--
 * @Date: 2021.04.27 17:32:32
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.05.25 16:21:07
-->

# FFmepg Generator Dart

[FFmepg Generator](https://github.com/fujiawei-dev/ffmpeg-generator) Dart language implementation, but only the core functions are implemented.

```dart
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
```

```
ffmpeg -hwaccel cuda -vcodec h264_cuvid -i C:/Users/Admin/Videos/FFmpeg/InputsData/v1.mp4 -filter_complex "[0]vflip[tag0]" -t 20.0 -map [tag0] C:/Users/Admin/Videos/FFmpeg/OutputsData/v1_output.mp4 -y -hide_banner
[10.79s]
```
