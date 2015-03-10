HTMLWidgets.widget({

  name: 'UtilityNetwork',

  type: 'output',

  initialize: function(el, width, height) {

    return {
      // TODO: add instance fields as required
    }

  },

  resize: function(el, width, height, instance) {
    //console.log("yep");
     if (instance.cy)
      instance.cy.resize();

  },


  renderValue: function(el, x, instance) {

    console.log(x.nodeEntries);
    console.log(x.edgeEntries);

    //var nodetest = JSON.parse(x.nodeEntries);
    //var edgetest = JSON.parse(x.edgeEntries);

    //console.log(nodetest);
    //console.log(edgetest);


  instance.cy = new cytoscape({
  container: el,
  style: cytoscape.stylesheet()
          	.selector('node')
            		.css({
                		'content': 'data(name)',
                		'text-valign': 'center',
                		'color': 'white',
                		'text-outline-width': 2,
                        'shape': 'data(shape)',
                        'text-outline-color': 'data(color)',
                        'background-color': 'data(color)'
            		})
        		.selector('edge')
        		    .css({
                    	'line-color': 'data(color)',
                        'source-arrow-color': 'data(color)',
                    	'target-arrow-color': 'data(color)',
                        'source-arrow-shape': 'data(edgeSourceShape)',
                		'target-arrow-shape': 'data(edgeTargetShape)'
            		})
    		.selector(':selected')
            		.css({
                		'background-color': 'black',
                		'line-color': 'black',
                		'target-arrow-color': 'black',
                		'source-arrow-color': 'black'
            		})
    		.selector('.faded')
            		.css({
                		'opacity': 0.25,
                		'text-opacity': 0
            		}),

  elements: {
    nodes: x.nodeEntries, //doesn't work due to data formatting
    //nodes: [{ data: { id:'509209821', name:'509209821', color:'#888888', shape:'ellipse', href:''} }, { data: { id:'531376085', name:'531376085', color:'#888888', shape:'ellipse', href:''} }],
    edges:  x.edgeEntries //same crap
      //edges: [{ data: { source:'509209821', target:'531376085', color:'#888888', edgeSourceShape:'none', edgeTargetShape:'triangle'} }]

    },

    		layout: {
    		    name: x.layout,
    		    padding: 10,
            ungrabifyWhileSimulating: true
    		},

            ready: function() {
                window.cy = this;

                cy.on('tap', 'node', function(event){
                    var nodes = this.closedNeighborhood().connectedNodes();
                    var obj = nodes._private.ids;
                    var keys = [];
                    for(var k in obj) keys.push(k);
                    //console.log(keys);
                    //console.log(this.closedNeighborhood().sources());
                    Shiny.onInputChange(el.id + "_click_node", keys);
                });

                cy.on('mousemove','node', function(event){
                //console.log(event);

                var target = event.cyTarget;
                var sourceName = target.data("id");
                var targetName = target.data("href");
                //console.log(sourceName);
                //console.log(targetName);


                var x=event.cyRenderedPosition.x;
                var y=event.cyRenderedPosition.y;
                //console.log("x="+x+" Y="+y);

                        $(el).qtip({
                            content: {
                                title: "DID: " + sourceName,
                                text: function(event, api) {
                                // Retrieve content from custom attribute of the $('.selector') elements.
                                return targetName;
                                }
                            },
                            show: {
                                delay: 0,
                                event: false,
                                ready: true,
                                effect:false

                            },
                            position: {

                                target: [x, y],
                                adjust: {
                                    x: 100,
                                    y: 100
                                }
                            },
                            hide: {
                                fixed: true,
                                event: false,
                                inactive: 2000

                            },


                            style: {
                                classes: 'ui-tooltip-shadow ui-tooltip-youtube',

                                tip:
                                {
                                    corner: true,
                                    width: 24,         // resize the caret
                                    height: 24         // resize the caret
                                }

                            }

                });
            });



            }
    	});


  }

});
