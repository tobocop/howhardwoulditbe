(function () {
  D3Test = {
    renderCharts: function () {
      D3Test.pieChart();
      D3Test.bulletChart();
    },

    pieChart: function() {
      var width = 960,
          height = 500,
          radius = Math.min(width, height) / 2;

      var color = d3.scale.ordinal()
          .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

      var arc = d3.svg.arc()
          .outerRadius(radius - 10)
          .innerRadius(0);

      var pie = d3.layout.pie()
          .sort(null)
          .value(function(d) { return d.population; });

      var svg = d3.select('.half.js-pie-chart').append("svg")
          .attr("width", width)
          .attr("height", height)
        .append("g")
          .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

      d3.json("/pie_chart_test_data", function(error, data) {
        data.forEach(function(d) {
          d.population = +d.population;
        });

        var g = svg.selectAll(".arc")
            .data(pie(data))
          .enter().append("g")
            .attr("class", "arc");

        g.append("path")
            .attr("d", arc)
            .style("fill", function(d) { return color(d.data.age); });

        g.append("text")
            .attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
            .attr("dy", ".35em")
            .style("text-anchor", "middle")
            .text(function(d) { return d.data.age; });
      });
    },

    bulletChart: function() {
      var margin = {top: 5, right: 40, bottom: 20, left: 120},
          width = 960 - margin.left - margin.right,
          height = 100 - margin.top - margin.bottom;

      var chart = d3.bullet()
          .width(width)
          .height(height);

      d3.json("/bullet_chart_test_data", function(error, data) {
        var svg = d3.select(".full.js-bullet-chart").selectAll("svg")
            .data(data)
          .enter().append("svg")
            .attr("class", "bullet")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
            .call(chart);

        var title = svg.append("g")
            .style("text-anchor", "end")
            .attr("transform", "translate(-6," + height / 2 + ")");

        title.append("text")
            .attr("class", "title")
            .text(function(d) { return d.title; });

        title.append("text")
            .attr("class", "subtitle")
            .attr("dy", "1em")
            .text(function(d) { return d.subtitle; });
      });
    }
  }
})(window);

$(function () {
  var D3Test_pages = ".js-partner-dashboard"

  if ($(D3Test_pages).length) {
    D3Test.renderCharts();
  }
});
