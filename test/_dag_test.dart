/*
 * @Date: 2021.04.27 12:41
 * @Description: Omit
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.04.27 12:41
 */
import 'package:ffmpeg_generator_dart/_dag.dart';

void main() {
  var node1 = DagNode('node1', {}, 'input', ['node1_arg'], {'node1_k': 'node1_v'});
  var edge1 = Edge(node1, node1.Label, 'node1_selector');

  var node3 = DagNode('node3', {edge1.Label: edge1}, 'filter', ['node3_arg'], {'node3_k': 'node3_v'});
  var edge2 = Edge(node3, node3.Label, 'edge2_selector');

  var node2 =
      DagNode('node2', {edge1.Label: edge1, edge2.Label: edge2}, 'output', ['node2_arg'], {'node2_k': 'node2_v'});

  var results = topological_sort([node2]);

  var nodes = results.item1;
  var outgoing_edge_graphs = results.item2;

  print(nodes);
  print(outgoing_edge_graphs);
  print(get_outgoing_edges(node1, outgoing_edge_graphs[node1] ?? {}));
}
