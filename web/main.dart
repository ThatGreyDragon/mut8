import 'dart:html';

class NodeClass {
	String name;
	String color;
	
	NodeClass(this.name, this.color) {}
}

@proxy
class NodeInstance {
	NodeClass nodeClass;
	int x, y;
	NodeInstance parent;
	List<NodeInstance> children;
	
	String get name => nodeClass.name;
	String get color => nodeClass.color;
	
	NodeInstance(this.nodeClass, [this.parent = null, this.children = null, this.x = 0, this.y = 0]) {
		if (this.children == null) {
			this.children = [];
		}
	}
}

class NodeGraph {
	String name;
	NodeInstance rootNode;
	List<NodeInstance> nodes = [];
	
	void draw(CanvasRenderingContext2D canvas) {
		canvas.clearRect(0, 0, canvas.canvas.width, canvas.canvas.height);
		
		// draw lines
		for (NodeInstance parent in nodes) {
			for (NodeInstance child in parent.children) {
				canvas.beginPath();
				canvas.fillStyle = "#000000";
				canvas.moveTo(parent.x, parent.y);
				canvas.lineTo(child.x, child.y);
				canvas.stroke();
			}
		}
		
		// draw nodes
		canvas.font = "36px serif";
		for (NodeInstance node in nodes) {
			int boxW = canvas.measureText(node.name).width;
			int boxH = 36;
			
			canvas.beginPath();
			canvas.fillStyle = "#666666";
			canvas.fillRect(node.x - boxW~/2 - 4, node.y - boxH~/2 - 4, boxW + 4, boxH + 4);
			canvas.stroke();
			
			canvas.beginPath();
			canvas.fillStyle = "#000000";
			canvas.rect(node.x - boxW~/2 - 4, node.y - boxH~/2 - 4, boxW + 4, boxH + 4);
			canvas.stroke();
			
			canvas.fillStyle = node.color;
			canvas.fillText(node.name, node.x - boxW~/2, node.y + boxH~/4);
		}
	}
	
	void addNode(NodeInstance node) {
		if (!nodes.contains(node)) {
			nodes.add(node);
		}
		
		if (node.parent != null && !node.parent.children.contains(node)) {
			node.parent.children.add(node);
		}
		
		for (NodeInstance child in node.children) {
			addNode(child);
		}
	}
	
	void handleEvents(CanvasRenderingContext2D canvas) {
		NodeInstance dragging;
		
		canvas.canvas.onMouseDown.capture((event) {
			int x = event.offset.x;
			int y = event.offset.y;
			
			for (NodeInstance node in nodes) {
				if (node.x > x-10 && node.x < x+10 && node.y > y-10 && node.y < y+10) {
					dragging = node;
					break;
				}
			}
		});
		
		canvas.canvas.onMouseUp.capture((event) {
			dragging = null;
		});
		
		canvas.canvas.onMouseMove.capture((event) {
			if (dragging != null) {
				dragging.x = event.offset.x;
				dragging.y = event.offset.y;
				draw(canvas);
			}
		});
	}
}

void main() {
	CanvasRenderingContext2D canvas = (querySelector("#node_graph") as CanvasElement).context2D;
	NodeGraph graph = new NodeGraph();
	
	NodeInstance soul = new NodeInstance(new NodeClass("SOUL", "#ff0000"), null, [], 300, 300);
	graph.addNode(soul);
	graph.addNode(new NodeInstance(new NodeClass("BODY", "#ffff00"), soul, [], 200, 200));
	
	graph.handleEvents(canvas);
	graph.draw(canvas);
}
