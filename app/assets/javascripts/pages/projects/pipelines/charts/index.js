import $ from 'jquery';
import Chart from 'chart.js';

const options = {
  scaleOverlay: true,
  responsive: true,
  maintainAspectRatio: false,
  legend: false,
  scales: {
    yAxes: [
      {
        ticks: {
          beginAtZero: true,
        },
      },
    ],
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

  const chart = new Chart(ctx, {
    type: 'line',
    data,
    options: {
      ...options,
      elements: {
        point: {
          hitRadius: (ctx.canvas.width - 10) / chartScope.totalValues.length,
        },
      },
      scales: {
        xAxes: [
          {
            ticks: {
              autoSkip: false,
              minRotation: 90,
            },
          },
        ],
        yAxes: [
          {
            ticks: {
              beginAtZero: true,
            },
          },
        ],
      },
      tooltips: {
        caretSize: 0,
        mode: 'x',
        intersect: false,
        multiKeyBackground: 'rgba(0,0,0,0)',
        callbacks: {
          labelColor({ datasetIndex }, { config }) {
            return {
              backgroundColor: config.data.datasets[datasetIndex].backgroundColor,
              borderColor: 'rgba(0,0,0,0)',
            };
          },
        },
      },
    },
  });
  window.addEventListener('resize', () => {
    chart.update({
      elements: {
        point: {
          hitRadius: (ctx.canvas.width - 10) / chartScope.totalValues.length,
        },
      },
    });
  });
};

document.addEventListener('DOMContentLoaded', () => {
  const chartTimesData = JSON.parse(document.getElementById('pipelinesTimesChartsData').innerHTML);
  const chartsData = JSON.parse(document.getElementById('pipelinesChartsData').innerHTML);
  chartTimesData.values = chartTimesData.values.map((_, i) => i * 10);
  const data = {
    labels: chartTimesData.labels,
    datasets: [
      {
        backgroundColor: 'rgba(220,220,220,0.5)',
        borderColor: 'rgba(220,220,220,1)',
        borderWidth: 1,
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

  /* eslint-disable no-new */
  new Chart(
    $('#build_timesChart')
      .get(0)
      .getContext('2d'),
    {
      type: 'bar',
      data,
      options: {
        ...options,
        tooltips: {
          mode: 'x',
          intersect: false,
          displayColors: false,
          callbacks: {
            title() {
              return '';
            },
            label({ xLabel, yLabel }) {
              return `${xLabel}: ${yLabel}`;
            },
          },
        },
      },
    },
  );

  /* eslint-enable no-new */

  chartsData.forEach(scope => buildChart(scope));
});
