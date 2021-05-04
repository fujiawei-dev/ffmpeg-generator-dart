/*
 * @Date: 2021.04.27 9:29
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.27 9:29
 */
import 'package:tuple/tuple.dart';

class Edge {
  final DagNode Node;
  final String Label;
  final String Selector;

  Edge(this.Node, this.Label, this.Selector);
}

class DagEdge {
  final DagNode DownstreamNode;
  final String DownstreamLabel;
  final DagNode UpstreamNode;
  final String UpstreamLabel;
  final String Selector;

  DagEdge(
    this.DownstreamNode,
    this.DownstreamLabel,
    this.UpstreamNode,
    this.UpstreamLabel,
    this.Selector,
  );
}

class DagNode {
  final String label;
  final Map<String, Edge> incoming_edge_graph;
  final String node_type;
  final List<String> args;
  final Map<String, dynamic> kwargs;

  String get brief => label;

  String get Label => label;

  String get Type => node_type;

  DagNode(this.label, this.incoming_edge_graph, this.node_type, this.args, this.kwargs);

  @override
  String toString() {
    return "<class 'DagNode:$Type'> $detail";
  }

  dynamic stream({String label = '', String selector = ''}) {
    throw UnimplementedError;
  }

  String get detail {
    var props = List<String>.from(args);
    var sortedKeys = kwargs.keys.toList()..sort();

    sortedKeys.forEach((key) {
      props.add('$key=${kwargs[key]}');
    });

    if (sortedKeys.isEmpty) {
      return brief;
    }

    return '$brief:${props.join(",")}';
  }

  List<DagEdge> get incoming_edges {
    return get_incoming_edges(this, incoming_edge_graph);
  }
}

List<DagEdge> get_incoming_edges(DagNode node, Map<String, Edge> incoming_edge_graph) {
  var incoming_edges = <DagEdge>[];
  incoming_edge_graph.forEach((label, edge) {
    incoming_edges.add(DagEdge(node, label, edge.Node, edge.Label, edge.Selector));
  });

  return incoming_edges;
}

List<DagEdge> get_outgoing_edges(DagNode node, Map<String, List<Edge>> outgoing_edge_graph) {
  var outgoing_edges = <DagEdge>[];
  outgoing_edge_graph.forEach((label, edges) {
    edges.forEach((edge) {
      outgoing_edges.add(DagEdge(edge.Node, edge.Label, node, label, edge.Selector));
    });
  });
  return outgoing_edges;
}

Tuple2<List<DagNode>, Map<DagNode, Map<String, List<Edge>>>> topological_sort(List<DagNode> nodes) {
  var outgoing_edge_graphs = <DagNode, Map<String, List<Edge>>>{};
  var outgoing_graph = <DagNode, List<DagNode>>{};
  var dependent_count = <DagNode, int>{};
  var sorted_nodes = <DagNode>[];
  var visited_nodes = <DagNode>{};

  while (nodes.isNotEmpty) {
    var node = nodes.removeLast();
    if (!visited_nodes.contains(node)) {
      node.incoming_edges.forEach((edge) {
        outgoing_graph[edge.UpstreamNode] ??= [];
        outgoing_graph[edge.UpstreamNode]!.add(node);

        outgoing_edge_graphs[edge.UpstreamNode] ??= {};
        outgoing_edge_graphs[edge.UpstreamNode]![edge.UpstreamLabel] ??= [];
        outgoing_edge_graphs[edge.UpstreamNode]![edge.UpstreamLabel]!
            .add(Edge(node, edge.DownstreamLabel, edge.Selector));

        nodes.add(edge.UpstreamNode);
      });
      visited_nodes.add(node);
    }
  }

  outgoing_graph.values.forEach((val) {
    val.forEach((v) {
      dependent_count[v] = (dependent_count[v] ?? 0) + 1;
    });
  });

  var stack = [
    for (var node in visited_nodes)
      if ((dependent_count[node] ?? 0) == 0) node
  ];

  while (stack.isNotEmpty) {
    var node = stack.removeLast();
    sorted_nodes.add(node);

    outgoing_graph[node]?.forEach((n) {
      dependent_count[n] = (dependent_count[n] ?? 1) - 1;
      if ((dependent_count[n] ?? 0) == 0) {
        stack.add(n);
      }
    });
  }

  if (sorted_nodes.length != visited_nodes.length) {
    throw 'This graph is not a DAG';
  }

  return Tuple2(sorted_nodes, outgoing_edge_graphs);
}
