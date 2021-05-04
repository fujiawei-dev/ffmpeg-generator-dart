/*
 * @Date: 2021.04.27 14:52
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.27 14:52
 */
import 'package:ffmpeg_generator_dart/_dag.dart';
import 'package:ffmpeg_generator_dart/nodes.dart';

import 'package:tuple/tuple.dart';

Map<String, Stream> get_stream_graph(dynamic stream_spec) {
  var stream_graph = <String, Stream>{};

  if (stream_spec is Map<String, Stream>) {
    stream_graph = stream_spec;
  } else if (stream_spec is List<Stream>) {
    stream_spec.asMap().forEach((key, value) {
      stream_graph[key.toString()] = value;
    });
  } else if (stream_spec is Stream) {
    stream_graph = {'None': stream_spec};
  }

  return stream_graph;
}

List<DagNode> get_stream_graph_nodes(Map<String, Stream> stream_graph) {
  var nodes = <DagNode>[];

  stream_graph.values.forEach((stream) {
    nodes.add(stream.Node);
  });

  return nodes;
}

List<DagNode> get_stream_spec_nodes(dynamic stream_spec) {
  return get_stream_graph_nodes(get_stream_graph(stream_spec));
}

class Stream extends Edge {
  Stream(DagNode upstream_node, String upstream_label, String selector)
      : super(upstream_node, upstream_label, selector);

  Stream operator [](String index) => this.Node.stream(label: Label, selector: index);

  Stream get audio => this['a'];

  Stream get video => this['v'];

  @override
  String toString() {
    var node = this.Node.toString();
    var selector = Selector != '' ? ':$Selector' : '';
    return '$node[$Label$selector]';
  }
}

class NodeTypes {
  static const String Base = 'Base';
  static const String Input = 'Input';
  static const String Filter = 'Filter';
  static const String Global = 'Global';
  static const String Output = 'Output';
  static const String Movie = 'movie';
}

class Node extends DagNode {
  final Stream Function(Node, String, String) _outgoing_stream_type;

  Node(String label, dynamic stream_spec, this._outgoing_stream_type,
      {int min_inputs = 0,
      int max_inputs = 0,
      String node_type = NodeTypes.Base,
      required List<String> args,
      required Map<String, dynamic> kwargs})
      : super(label, _get_incoming_edge_graph(get_stream_graph(stream_spec)), node_type, args, kwargs);

  @override
  dynamic stream({String label = '', String selector = ''}) {
    return _outgoing_stream_type(this, label, selector);
  }

  dynamic operator [](List<String> index) {
    if (index.length == 1) {
      return stream(label: index[0]);
    } else if (index.length == 2) {
      return stream(label: index[0], selector: index[1]);
    }
    return stream();
  }

  String get_filter_spec(List<DagEdge> edges) {
    throw UnimplementedError;
  }

  List<String> get_input_args() {
    throw UnimplementedError;
  }

  List<String> get_output_args(Map<Tuple2<DagNode, String>, String> stream_tag_graph) {
    throw UnimplementedError;
  }

  List<String> get_global_args() {
    throw UnimplementedError;
  }

  static Map<String, Edge> _get_incoming_edge_graph(Map<String, Stream> stream_graph) {
    var incoming_edge_graph = <String, Edge>{};
    stream_graph.forEach((downstream_label, upstream) {
      incoming_edge_graph[downstream_label] = upstream;
    });
    return incoming_edge_graph;
  }
}

String format_input_stream_tag(Map<Tuple2<DagNode, String>, String> stream_tag_graph, DagEdge edge,
    {bool is_final = false}) {
  var prefix = stream_tag_graph[Tuple2(edge.UpstreamNode, edge.UpstreamLabel)];
  var suffix = edge.Selector != '' ? ':${edge.Selector}' : '';

  var _format = '[$prefix$suffix]';
  if (is_final && edge.UpstreamNode.Type == NodeTypes.Input) {
    _format = '$prefix$suffix';
  } else if (edge.DownstreamNode.Label == NodeTypes.Movie) {
    _format = '';
  } else if (edge.UpstreamNode.Label == NodeTypes.Movie) {
    _format = '[0][$prefix$suffix]';
  }

  return _format;
}

String format_output_stream_tag(
  Map<Tuple2<DagNode, String>, String> stream_tag_graph,
  DagEdge edge,
) {
  return '[${stream_tag_graph[Tuple2(edge.UpstreamNode, edge.UpstreamLabel)]}]';
}

String get_filter_spec(
  Node node,
  Map<String, List<Edge>> outgoing_edge_graph,
  Map<Tuple2<DagNode, String>, String> stream_tag_graph,
) {
  var incoming_edges = node.incoming_edges;
  var outgoing_edges = get_outgoing_edges(node, outgoing_edge_graph);

  var inputs = [for (var edge in incoming_edges) format_input_stream_tag(stream_tag_graph, edge)];
  var outputs = [for (var edge in outgoing_edges) format_output_stream_tag(stream_tag_graph, edge)];

  return "${inputs.join('')}${node.get_filter_spec(outgoing_edges)}${outputs.join('')}";
}

void allocate_filter_stream_tags(
  List<Node> filter_nodes,
  Map<Tuple2<DagNode, String>, String> stream_tag_graph,
  Map<DagNode, Map<String, List<Edge>>> outgoing_edge_graphs,
) {
  var current_serial_number = 0;

  filter_nodes.forEach((upstream_node) {
    var outgoing_edge_graph = outgoing_edge_graphs[upstream_node];
    outgoing_edge_graph!.forEach((upstream_label, downstreams) {
      if (downstreams.length > 1) {
        throw 'Encountered $upstream_node with multiple outgoing edges with '
            'same upstream label $upstream_label; a `split` filter is probably required';
      }
      stream_tag_graph[Tuple2(upstream_node, upstream_label)] = 'tag$current_serial_number';
      current_serial_number += 1;
    });
  });
}

String get_filters_spec(
  List<FilterNode> filter_nodes,
  Map<Tuple2<DagNode, String>, String> stream_tag_graph,
  Map<DagNode, Map<String, List<Edge>>> outgoing_edge_graphs,
) {
  allocate_filter_stream_tags(filter_nodes, stream_tag_graph, outgoing_edge_graphs);
  return [for (var node in filter_nodes) get_filter_spec(node, outgoing_edge_graphs[node]!, stream_tag_graph)]
      .join(';');
}
