HTMLWidgets.widget({

  name: 'UtilityNetwork',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  resize: function(el, width, height, instance) {

  },


  renderValue: function(el, x, instance) {

  instance.cy = new cytoscape({
  container: el,

  elements: [
    { // node n1
      group: 'nodes', // 'nodes' for a node, 'edges' for an edge

      // NB: id fields must be strings
      data: { // element data (put dev data here)
        id: 'n1', // mandatory for each element, assigned automatically on undefined
        parent: 'nparent', // indicates the compound node parent id; not defined => no parent
      },

      position: { // the model position of the node (optional on init, mandatory after)
        x: 100,
        y: 100
      },

      selected: false, // whether the element is selected (default false)

      selectable: true, // whether the selection state is mutable (default true)

      locked: false, // when locked a node's position is immutable (default false)

      grabbable: true, // whether the node can be grabbed and moved by the user

      classes: 'foo bar', // a space separated list of class names that the element has

      // NB: you should only use `css` for very special cases; use classes instead
      css: { 'background-color': 'red' } // overriden style properties
    },

    { // node n2
      group: 'nodes',
      data: { id: 'n2' },
      renderedPosition: { x: 200, y: 200 } // can alternatively specify position in rendered on-screen pixels
    },

    { // node n3
      group: 'nodes',
      data: { id: 'n3', parent: 'nparent' },
      position: { x: 123, y: 234 }
    },

    { // node nparent
      group: 'nodes',
      data: { id: 'nparent', position: { x: 200, y: 100 } }
    },

    { // edge e1
      group: 'edges',
      data: {
        id: 'e1',
        source: 'n1', // the source node id (edge comes from this node)
        target: 'n2'  // the target node id (edge goes to this node)
      }
    }
  ],

  layout: {
    name: 'preset'
  },

  // so we can see the ids
  style: [
    {
      selector: 'node',
      css: {
        'content': 'data(id)'
      }
    }
  ]

});


  }

});
