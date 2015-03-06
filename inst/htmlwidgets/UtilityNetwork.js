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

  var instance.cy = cytoscape({
  container: el,
  ready: function(){ console.log('ready') }
  });


  }

});
