enum DateFilterOption {
  all('All Time'),
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  custom('Custom Range');

  final String label;
  const DateFilterOption(this.label);
}
