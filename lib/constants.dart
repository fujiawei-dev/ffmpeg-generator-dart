/*
 * @Date: 2021.04.29 21:33
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.29 21:33
 */
var VIDEO_SOURCES = {
  'allrgb',
  'allyuv',
  'color',
  'haldclutsrc',
  'nullsrc',
  'pal75bars',
  'pal100bars',
  'rgbtestsrc',
  'smptebars',
  'smptehdbars',
  'testsrc',
  'testsrc2',
  'yuvtestsrc'
};

const H264_NVENC = 'h264_nvenc';
const HEVC_NVENC = 'hevc_nvenc';

const H264_CUVID = 'h264_cuvid';
const HEVC_CUVID = 'hevc_cuvid';
const MJPEG_CUVID = 'mjpeg_cuvid';
const MPEG1_CUVID = 'mpeg1_cuvid';
const MPEG2_CUVID = 'mpeg2_cuvid';
const MPEG4_CUVID = 'mpeg4_cuvid';
const VC1_CUVID = 'vc1_cuvid';
const VP8_CUVID = 'vp8_cuvid';
const VP9_CUVID = 'vp9_cuvid';

const REAL_TIME = '%{localtime:%Y-%m-%d %H-%M-%S}';

const COPY = 'copy';
const RAW_VIDEO = 'rawvideo';
const S16LE = 's16le';

const RGB24 = 'rgb24';
const PCM_S16LE = 'pcm_s16le';

const PTS_STARTPTS = 'PTS-STARTPTS';

const PIPE = 'pipe:';

const HD = '1280x720';
const FHD = '1920x1080';
const QHD = '2560x1440';
const UHD = '3840x2160';

var IMAGE_FORMATS = {'.bmp', '.gif', '.heif', '.jpeg', '.jpg', '.png', '.raw', '.tiff'};

const JSON_FORMAT = 'json';
