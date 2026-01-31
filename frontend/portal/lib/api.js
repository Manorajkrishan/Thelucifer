/**
 * If response is 401, clear token and redirect to login.
 * Call this after fetch() and before reading body.
 * @param {Response} response - fetch response
 * @returns {boolean} true if 401 was handled (caller should return), false otherwise
 */
export function handleUnauthorized(response) {
  if (response.status === 401) {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return true
  }
  return false
}
