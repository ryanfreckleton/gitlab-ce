export const commonTooltips = () => ({
  mode: 'x',
  intersect: false,
});

export const barChartTooltips = () => ({
  ...commonTooltips(),
  displayColors: false,
  callbacks: {
    title() {
      return '';
    },
    label({ xLabel, yLabel }) {
      return `${xLabel}: ${yLabel}`;
    },
  },
});

export const yAxesConfig = () => ({
  yAxes: [
    {
      ticks: {
        beginAtZero: true,
      },
    },
  ],
});

export const chartOptions = () => ({
  responsive: true,
  maintainAspectRatio: false,
  legend: false,
});
