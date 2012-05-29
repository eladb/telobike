$(function() {
  Backbone.Events.once = function(evt, fn) {
    var _fn = function() {
      this.off(evt, _fn);
      fn.call(arguments);
    };
    this.on(evt, _fn);
  };

  // -----
  // -- Data model

  var fetched = false;

  var StationCollection = Backbone.Collection.extend({
    model: Backbone.Model.extend(),
    url: '/tlv/stations',
  });

  var stations = new StationCollection();

  StationCollection.prototype.once = Backbone.Events.once;

  stations.fetch({
    success: function() { fetched = true; }
  });

  stations.once('reset', function() {
    fetched = true;
  });

  // -----
  // -- Router

  var Router = Backbone.Router.extend({
    routes: {
      '': 'handle_station',
      'tlv/stations/:id': 'handle_station'
    },

    handle_station: function(id) {
      if (!fetched) {
        stations.once('reset', function() {
          router.trigger('station', id, stations.get(id));
        });
      }
      router.trigger('station', id, stations.get(id));
    },
  });

  var router = new Router();

  // -----
  // -- Views

  var StationListItemView = Backbone.View.extend({
    tagName: 'li',
    template: _.template($('#tpl-station-list-item').html()),
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    },
  });

  var StationListView = Backbone.View.extend({
    tagName: 'ul',
    className: 'nav nav-list',

    initialize: function() {
      this.model.on('reset', this.render, this);

      this.items = {};
      this.selected = null;

      var self = this;

      router.on('station', function(id) {
        self.select(id);
      });
    },

    render: function() {
      console.log('RENDER_LIST_VIEW');
      
      var self = this;
      $(self.el).empty();

      var i = 0;

      _.each(this.model.models, function(model) {

        //if (i++ > 10) return;


        var station = model.toJSON();

        var item = self.items[station.id];
        if (!item) {
          item = new StationListItemView({ model: model, map: self.map });
          self.items[station.id] = item;
        }

        var html = item.render();
        return $(self.el).append(html.el);
      });

      $('#listArea').html(this.el);

      return this;
    },

    select: function(id) {
      if (this.selected) {
        $(this.selected.el).removeClass('active');
        this.selected = null;
      }
      var item = this.items[id];
      if (!item) return;
      $(item.el).addClass('active');
      this.selected = item;
    },
  });

  var StationMapView = Backbone.View.extend({
    el: $('#map_canvas')[0],

    infoTemplate: _.template($('#tpl-station-info').html()),

    initialize: function() {
      console.log('INIT_MAP_VIEW');
      var options = {
        zoom: 12,
        center: new google.maps.LatLng(32.073847, 34.778595),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      this.map = new google.maps.Map(this.el, options);
      this.markers = {};
      this.selected = null;

      var self = this;

      this.model.on('reset', this.render, this);
      router.on('station', function(id) {
        self.select(id);
      });
    },

    render: function() {
      console.log('RENDER_MAP_VIEW');
      var self = this;

      _.each(this.model.models, function(model) {
        var station = model.toJSON();
        var location = new google.maps.LatLng(station.latitude, station.longitude);

        var m = self.markers[station.id] || { };
        self.markers[station.id] = m;

        m.station = station;

        if (!m.infowindow) {
          m.infowindow = new google.maps.InfoWindow({ 
            content: self.infoTemplate(station) 
          });
        }

        if (!m.marker) {
          m.marker = new google.maps.Marker({
            position: location,
            map: self.map,
            title: station.name_en,
          });

          google.maps.event.addListener(m.marker, 'click', function() {
            window.location.href = '/#/tlv/stations/' + station.id;
          });
        }

      });
    },

    select: function(id) {
      if (this.selected) {
        this.selected.infowindow.close();
        this.selected = null;
      }

      var m = this.markers[id];
      if (!m) return;
      m.infowindow.open(this.map, m.marker);
      this.selected = m;
    },
  });

  var StationDetailsView = Backbone.View.extend({
    tagName: 'div',
    template: _.template($('#tpl-station-details').html()),
    initialize: function() {
      router.on('station', function(id, station) {
        detailsView.model = station;
        detailsView.render();
      });
    },
    render: function() {
      if (!this.model) {
        $('#details').html('');
        return;
      }

      console.log('RENDER_DETAILS_VIEW');
      var station = this.model.toJSON();
      this.$el.html(this.template(station));
      $('#details').html(this.el);
      return this;
    },
  });

  var StationNameView = Backbone.View.extend({
    initialize: function() {
      var self = this;
      stations.on('reset', this.render, this);
      router.on('station', function(id, station) {
        self.model = station;
        self.render();
      });
    },
    render: function() {
      if (!this.model) {
        $('li#station_name a').html('');
        $('li#home').addClass('active');
        $('li#station_name').removeClass('active');
        return;
      }

      $('li#station_name a').html(this.model.toJSON().name_en);
      $('li#home').removeClass('active');
      $('li#station_name').addClass('active');
      return this;
    },
  });

  var listView = new StationListView({ model: stations });
  var mapView = new StationMapView({ model: stations });
  var detailsView = new StationDetailsView({ model: null });
  new StationNameView({ model: null });

  $('#reload').click(function() {
    stations.fetch();
  });
  
  Backbone.history.start();
});