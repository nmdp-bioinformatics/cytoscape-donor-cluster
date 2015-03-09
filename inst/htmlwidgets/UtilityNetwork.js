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
    		    padding: 10
    		},

            ready: function() {
                window.cy = this;

                //cy.on('tap', 'node', function(){
                    //if(this.data('href').length > 0) {
                    //    alert(this.data('href'));
                    //}
                    //console.log(this.data('href'));
                //});

                cy.on('mousemove','node', function(event){

                var target = event.cyTarget;
                var sourceName = target.data("id");
                var targetName = target.data("href");
                console.log(sourceName);
                console.log(targetName);


                var x=event.cyPosition.x;
                var y=event.cyPosition.y;


                        $("#blahh").qtip({
                            content: {
                                title:targetName,
                                text: sourceName
                            },
                            show: {
                                delay: 0,
                                event: false,
                                ready: true,
                                effect:false

                            },
                            position: {
                                my: 'bottom center',
                                at: 'top center',

                                target: [x, y],
                                adjust: {
                                    x: -7,
                                    y:-7

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
