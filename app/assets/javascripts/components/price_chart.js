/*global window, google, clearTimeout, setTimeout, jQuery*/
(function ($) {
  "use strict";

  var PriceCharts = {
    element: null,
    from: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 10),
    to: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1),
    period: "last 10 days",
    init: function (element) {
      this.element = element;
      var self = this;
      this.callbacks();
      if (this.element) {
        $.when(
          self.loadCharts(),
          self.data()
        ).then(function () {
          self.render();
        });
      }
    },

    callbacks: function () {
      var doit;
      var self = this;
      $("[data-chart-period]").on("click", function () {
        self.from = new Date($(this).data("from"));
        self.to = new Date($(this).data("to"));
        self.render();
      });

      function redraw() {
        self.render();
      }

      $(window).resize(function () {
        clearTimeout(doit);
        doit = setTimeout(redraw, 100);
      });
    },

    loadCharts: function () {
      var chartsLoaded = $.Deferred();

      google.charts.load("current", {"packages": ["corechart"]});
      google.charts.setOnLoadCallback(function () {
        chartsLoaded.resolve();
      });

      return chartsLoaded;
    },

    data: function () {
      var self = this,
        dataLoaded = $.Deferred(),
        data = [];

      $.get(
        self.element.data("url"),
        function (results) {
          $.each(results, function (i, r) {
            data.push([new Date(r.date), r.low, r.open, r.close, r.high]);
          });
          dataLoaded.resolve(data);
        },
        "json"
      );

      return dataLoaded;
    },

    render: function () {
      var self = this,
        dataTable;

      this.data().done(function (data) {

        dataTable = new google.visualization.DataTable();
        dataTable.addColumn("date");
        dataTable.addColumn("number");
        dataTable.addColumn("number");
        dataTable.addColumn("number");
        dataTable.addColumn("number");
        dataTable.addColumn({type: "string", role: "tooltip", p: { "html": true }});

        // var dataTable = google.visualization.arrayToDataTable(self.filter(data), true);

        dataTable.addRows(
          self.generateToolTip(
            self.group(
              self.filter(data)
            )
          )
        );

        var options = {
          "animation.duration": 1000,
          "animation.startup": true,
          legend: "none",
          candlestick: {
            fallingColor: { stroke: "#a52714" }, // red
            risingColor: { stroke: "#999", fill: "#999" }   // green
          },
          chartArea: {
            left: 50,
            top: 20,
            width: self.element.width() - 50, // left
            height: 300 - 20 - 30 // top and bottom
          },
          focusTarget: "category",
          series: [{color: "#000"}],
          // title: self.period
          tooltip: { showColorCode: false, isHtml: true }
        },
          chart = new google.visualization.CandlestickChart(self.element[0]);

        chart.draw(dataTable, options);

      });
    },

    filter: function (data) {
      var self = this,
        date;

      return data.filter(function (row) {
        date = row[0];
        return date >= self.from && date <= self.to;
      });
    },

    generateToolTip: function (data) {
      var tooltip,
        results = [];

      function format(number) {
        var parts = (number.toString() + ".").split("."),
          decimal = (parts[1] + "00");
        return "$" + parts[0] + "." + decimal.substr(0, 2);
      }

      $.each(data, function (i, row) {
        tooltip =
          '<div class="price-tooltip" style="width: 120px">' +
            '<div class="price-tooltip--names" style="width: 60px; display: inline-block; padding-right: 10px; text-align: right">' +
              "<div>Open:</div><div>Low:</div><div>High:</div><div>Close:</div>" +
            '</div>' +
            '<div class="price-tooltip--values" style="width: 50px; display: inline-block; font-weight: bold">' +
              '<div>' + format(row[2]) + "</div><div>" + format(row[1]) + "</div><div>" + format(row[4]) + "</div><div>" + format(row[3]) + "</div>" +
            '</div>' +
          '</div>';

        results.push([row[0], row[1], row[2], row[3], row[4], tooltip]);
      });
      return results;
    },

    group: function (data) {
      function groupBy(groupMethod) {
        var startDate,
          keys = [],
          grouped = data.reduce(function (acc, row) {
            startDate = groupMethod(row[0]).toJSON();
            if (acc[startDate] === undefined) {
              keys.push(startDate);
              acc[startDate] = [];
            }
            acc[startDate].push(row);
            return acc;
          }, {});
        return keys.map(function (key) {
          var rows = grouped[key];
          return [
            rows[0][0],
            Math.max.apply(null, rows.map(function (x) { return x[1]; })),
            rows[0][2],
            rows[rows.length - 1][3],
            Math.max.apply(null, rows.map(function (x) { return x[4]; }))
          ];
        });
      }

      var mutilplier = this.element.width() > 1000 ? 8 : (this.element.width() > 700 ? 4 : 2);
      if(data.length > 7 * mutilplier * mutilplier) {
        // months
        return groupBy(function (date) {
          return new Date(date.getFullYear(), date.getMonth(), 1);
        });
      } else if(data.length > 7 * mutilplier) {
        // weeks
        return groupBy(function (date) {
          return new Date(date.getFullYear(), date.getMonth(), date.getDate() - date.getDay());
        });
      } else {
        return data;
      }
    }
  };

  window.PriceCharts = PriceCharts;

  var chart = $('#chart_div');
  if(chart) {
    PriceCharts.init(chart);
  }
})(jQuery);
