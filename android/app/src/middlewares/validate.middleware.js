const { validationResult } = require('express-validator');
const { sendError } = require('../utils/response.util');

/**
 * Validate request using express-validator
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => ({
      field: err.path || err.param,
      message: err.msg,
    }));

    return sendError(res, 'Validation failed', 400, errorMessages);
  }

  next();
};

/**
 * Validate with Joi schema
 */
const validateSchema = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errorMessages = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return sendError(res, 'Validation failed', 400, errorMessages);
    }

    // Replace req.body with validated value
    req.body = value;
    next();
  };
};

module.exports = {
  validate,
  validateSchema,
};