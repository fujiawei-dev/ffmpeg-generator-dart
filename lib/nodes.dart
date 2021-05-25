/*
 * @Date: 2021.04.29 11:04
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.05.25 16:07:40
 */
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:ffmpeg_generator_dart/_dag.dart';
import 'package:ffmpeg_generator_dart/_node.dart';
import 'package:ffmpeg_generator_dart/_utils.dart';
import 'package:tuple/tuple.dart';

import 'pkgs/color.dart' as color;
import 'constants.dart';
import 'settings.dart';

class OutputStream extends Stream {
  OutputStream(
    DagNode upstream_node,
    String upstream_label,
    String selector,
  ) : super(upstream_node, upstream_label, selector);

  OutputStream with_global_args(List<String> args) {
    return GlobalNode(this, args: args, kwargs: {}).stream();
  }

  OutputStream merge_outputs(List<Stream> streams) {
    return MergeOutputsNode(<Stream>[this] + streams).stream();
  }

  List<String> get_output_args({bool overwrite = true}) {
    var nodes = get_stream_spec_nodes(this);

    var results = topological_sort(nodes);
    var sorted_nodes = results.item1;
    var outgoing_edge_graphs = results.item2;
    var stream_tag_graph = <Tuple2<DagNode, String>, String>{};

    var type_nodes = <String, List<dynamic>>{};
    sorted_nodes.forEach((node) {
      type_nodes[node.Type] ??= [];
      type_nodes[node.Type]!.add(node);
    });

    var index = 0;
    var args = <String>[];

    (type_nodes[NodeTypes.Input] ?? []).forEach((node) {
      stream_tag_graph[Tuple2(node, '')] = (index++).toString();
      args += node.get_input_args();
    });

    var filters_spec = get_filters_spec(
      (type_nodes[NodeTypes.Filter] ?? []).cast(),
      stream_tag_graph,
      outgoing_edge_graphs,
    );

    if (filters_spec != '') {
      args += ['-filter_complex', filters_spec];
    }

    (type_nodes[NodeTypes.Output] ?? []).forEach((node) {
      args += node.get_output_args(stream_tag_graph);
    });

    (type_nodes[NodeTypes.Global] ?? []).forEach((node) {
      args += node.get_global_args();
    });

    if (overwrite) {
      args.add('-y');
    }

    args.add('-hide_banner');

    return args;
  }

  List<String> compile({
    String executable = 'ffmpeg',
    bool direct_print = true,
    bool overwrite = true,
  }) {
    var cmd_args_seq = [executable] + get_output_args(overwrite: overwrite);
    var command = join_cmd_args_seq(cmd_args_seq);

    if (direct_print) {
      color.greenln(command);
    }

    return cmd_args_seq;
  }

  Future<void> run({
    String executable = 'ffmpeg',
    bool direct_print = true,
    bool overwrite = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    var cmd_args_seq = compile(
      executable: executable,
      direct_print: direct_print,
      overwrite: overwrite,
    );

    await Process.run(cmd_args_seq[0], cmd_args_seq.sublist(1));

    color.redln('[${(stopwatch.elapsed.inMilliseconds / 1000).toStringAsFixed(2)}s]');
  }
}

class FilterableStream extends Stream {
  FilterableStream(
    DagNode upstream_node,
    String upstream_label,
    String selector,
  ) : super(upstream_node, upstream_label, selector);

  OutputStream output(
    List streams_or_source, {
    String acodec = '',
    String vcodec = '',
    String codec = '',
    String format = '',
    String pixel_format = '',
    double duration = 0,
    double fps = 0,
    double start_position = 0,
    String video_filter = '',
    String audio_filter = '',
    bool vn = false,
    bool an = false,
    bool shortest = false,
    bool enable_cuda = false,
    required List args,
    required Map<String, dynamic> kwargs,
  }) {
    if (vn) {
      args.add('-vn');
    }
    if (an) {
      args.add('-an');
    }
    if (shortest) {
      args.add('-shortest');
    }

    if (!kwargs.containsKey('source')) {
      kwargs['source'] = streams_or_source.removeLast();
    }
    var streams = streams_or_source;

    if (CUDA_ENABLE && enable_cuda && !IMAGE_FORMATS.contains(path.extension(kwargs['source']))) {
      kwargs['hwaccel'] = 'cuda';
      kwargs['vcodec'] = DEFAULT_DECODER;
    }

    if (acodec != '') {
      kwargs['acodec'] = acodec;
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
    if (fps != 0) {
      kwargs['r'] = fps;
    }

    return OutputNode([this] + streams.cast(), args: args.cast(), kwargs: kwargs).stream();
  }

  FilterNode filter_multi_output(
    List<Stream> stream_spec,
    String label,
    List args,
    Map<String, dynamic> kwargs,
  ) {
    var max_inputs = kwargs.remove('max_inputs') ?? 1;
    var min_inputs = kwargs.remove('min_inputs') ?? 1;

    return FilterNode(
      <Stream>[this] + stream_spec,
      label,
      min_inputs: min_inputs,
      max_inputs: max_inputs,
      args: args.cast(),
      kwargs: kwargs,
    );
  }

  FilterableStream filter(String label, List args, Map<String, dynamic> kwargs) {
    return filter_multi_output([], label, args, kwargs).stream();
  }
}

class InputNode extends Node {
  InputNode({required List<String> args, required Map<String, dynamic> kwargs})
      : assert(kwargs['source'] != null),
        super(
            NodeTypes.Input,
            {},
            (Node upstream_node, String upstream_label, String selector) =>
                FilterableStream(upstream_node, upstream_label, selector),
            node_type: NodeTypes.Input,
            args: args,
            kwargs: kwargs);

  String get source => kwargs['source'];

  @override
  String get brief => path.basename(source);

  @override
  List<String> get_input_args() {
    var _kwargs = kwargs;
    var _source = _kwargs.remove('source');
    return convert_kwargs_to_cmd_line_args(_kwargs) + ['-i', _source];
  }
}

class OutputNode extends Node {
  OutputNode(
    List<Stream> streams, {
    required List<String> args,
    required Map<String, dynamic> kwargs,
  })  : assert(kwargs['source'] != null),
        super(
          NodeTypes.Output,
          streams,
          (Node upstream_node, String upstream_label, String selector) =>
              OutputStream(upstream_node, upstream_label, selector),
          min_inputs: 1,
          node_type: NodeTypes.Output,
          args: args,
          kwargs: kwargs,
        );

  String get source => kwargs['source'];

  @override
  String get brief => path.basename(source);

  @override
  List<String> get_output_args(Map<Tuple2<DagNode, String>, String> stream_tag_graph) {
    if (incoming_edges.isEmpty) {
      throw '${this} has no mapped streams';
    }

    var _args = args;
    var _kwargs = kwargs;
    String _source = _kwargs.remove('source');

    incoming_edges.forEach((edge) {
      var stream_tag = format_input_stream_tag(stream_tag_graph, edge, is_final: true);
      if (stream_tag != '0' || incoming_edges.length > 1) {
        _args += ['-map', stream_tag];
      }
    });

    return convert_kwargs_to_cmd_line_args(_kwargs) + _args + [_source];
  }
}

class FilterNode extends Node {
  final special_filters = {'split', 'asplit'};

  FilterNode(
    List<Stream> streams,
    String label, {
    int min_inputs = 0,
    int max_inputs = 0,
    required List<String> args,
    required Map<String, dynamic> kwargs,
  }) : super(
            label,
            streams,
            (Node upstream_node, String upstream_label, String selector) =>
                FilterableStream(upstream_node, upstream_label, selector),
            min_inputs: min_inputs,
            max_inputs: max_inputs,
            node_type: NodeTypes.Filter,
            args: args,
            kwargs: kwargs);

  @override
  String get_filter_spec(List<DagEdge> outgoing_edges) {
    var _args = <String>[];
    var _kwargs = <String, String>{};

    if (special_filters.contains(Label) && outgoing_edges.isNotEmpty) {
      _args = [outgoing_edges.length.toString()];
    } else {
      _args = [for (var x in args) escape(x, '\\\'=:')];
    }

    kwargs.forEach((k, v) {
      _kwargs[escape(k, '\\\'=:')] = escape(v, '\\\'=:');
    });

    for (var key in _kwargs.keys.toList()..sort()) {
      _args.add('$key=${_kwargs[key]}');
    }
    ;

    var params = '';

    if (_args.isNotEmpty) {
      params = escape(Label, '\\\'=:') + '=' + _args.join(':');
    } else {
      params = escape(Label, '\\\'=:');
    }

    return escape(params, '\\\'[],;');
  }
}

class GlobalNode extends Node {
  GlobalNode(
    Stream stream, {
    required List<String> args,
    required Map<String, dynamic> kwargs,
  }) : super(
            stream.Label,
            stream,
            (Node upstream_node, String upstream_label, String selector) =>
                OutputStream(upstream_node, upstream_label, selector),
            min_inputs: 1,
            max_inputs: 1,
            node_type: NodeTypes.Global,
            args: args,
            kwargs: kwargs);
}

class MergeOutputsNode extends Node {
  MergeOutputsNode(List<Stream> streams)
      : super(
            '',
            streams,
            (Node upstream_node, String upstream_label, String selector) =>
                OutputStream(upstream_node, upstream_label, selector),
            node_type: 'merge_outputs',
            args: [],
            kwargs: {});
}
