///|
/// Inline value helpers.

///|
pub fn InlineValue::from_text(value : InlineValueText) -> InlineValue {
  InlineValue::Text(value)
}

///|
pub fn InlineValue::from_variable_lookup(
  value : InlineValueVariableLookup,
) -> InlineValue {
  InlineValue::VariableLookup(value)
}

///|
pub fn InlineValue::from_evaluatable_expression(
  value : InlineValueEvaluatableExpression,
) -> InlineValue {
  InlineValue::EvaluatableExpression(value)
}
