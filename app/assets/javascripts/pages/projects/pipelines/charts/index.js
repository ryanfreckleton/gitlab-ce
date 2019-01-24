import $ from 'jquery';
import Chart from 'chart.js';

const options = {
  responsive: true,
  maintainAspectRatio: false,
  legend: false,
  tooltips: {
    mode: 'x',
    intersect: false,
    multiKeyBackground: 'rgba(0,0,0,0)',
    callbacks: {
      labelColor(tooltipItem, _chart) {
        return {
          backgroundColor: _chart.config.data.datasets[tooltipItem.datasetIndex].backgroundColor,
          borderColor:  'rgba(0,0,0,0)',
        };
      },
    },
  },
};

const buildChart = chartScope => {
  const data = {
    labels: chartScope.labels,
    datasets: [
      {
        backgroundColor: '#1aaa55',
        borderColor: '#1aaa55',
        pointBackgroundColor: '#1aaa55',
        pointBorderColor: '#fff',
        data: chartScope.successValues,
        fill: 'origin',
      },
      {
        backgroundColor: '#707070',
        borderColor: '#707070',
        pointBackgroundColor: '#707070',
        pointBorderColor: '#EEE',
        data: chartScope.totalValues,
        fill: '-1',
      },
    ],
  };
  const ctx = $(`#${chartScope.scope}Chart`)
    .get(0)
    .getContext('2d');

  new Chart(ctx, {
    type: 'line',
    data,
    options,
  });
};

document.addEventListener('DOMContentLoaded', () => {
  const chartTimesData = JSON.parse(document.getElementById('pipelinesTimesChartsData').innerHTML);
  const chartsData = JSON.parse(document.getElementById('pipelinesChartsData').innerHTML);
  const data = {
    labels: chartTimesData.labels,
    datasets: [
      {
        fillColor: 'rgba(220,220,220,0.5)',
        strokeColor: 'rgba(220,220,220,1)',
        barStrokeWidth: 1,
        barValueSpacing: 1,
        barDatasetSpacing: 1,
        data: chartTimesData.values,
      },
    ],
  };

  if (window.innerWidth < 768) {
    // Scale fonts if window width lower than 768px (iPad portrait)
    options.scaleFontSize = 8;
  }

  // new Chart(
  //   $('#build_timesChart')
  //     .get(0)
  //     .getContext('2d'),
  //   {
  //     type: 'bar',
  //     data,
  //     options,
  //   },
  // );

  chartsData.forEach(scope => buildChart(scope));
});
