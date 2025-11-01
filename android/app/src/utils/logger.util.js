const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

/**
 * Format log message
 */
const formatMessage = (level, message, data = null) => {
  const timestamp = new Date().toISOString();
  let log = `[${timestamp}] [${level}] ${message}`;

  if (data) {
    log += '\n' + JSON.stringify(data, null, 2);
  }

  return log;
};

/**
 * Log levels
 */
const logger = {
  info: (message, data = null) => {
    console.log(colors.cyan + formatMessage('INFO', message, data) + colors.reset);
  },

  success: (message, data = null) => {
    console.log(colors.green + formatMessage('SUCCESS', message, data) + colors.reset);
  },

  warn: (message, data = null) => {
    console.warn(colors.yellow + formatMessage('WARN', message, data) + colors.reset);
  },

  error: (message, data = null) => {
    console.error(colors.red + formatMessage('ERROR', message, data) + colors.reset);
  },

  debug: (message, data = null) => {
    if (process.env.LOG_LEVEL === 'debug') {
      console.log(colors.magenta + formatMessage('DEBUG', message, data) + colors.reset);
    }
  },
};

module.exports = logger;