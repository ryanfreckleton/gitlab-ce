export default class RecentSearchesServiceError extends Error {
  constructor(message) {
    super(message);
    this.name = 'RecentSearchesServiceError';
    this.message = message || 'Recent Searches Service is unavailable';
  }
}
