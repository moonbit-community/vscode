///|
/// Decoration option helpers.

///|
pub(all) enum OverviewRulerLane {
  Left = 1
  Center = 2
  Right = 4
  Full = 7
} derive(Eq)

///|
pub(all) enum DecorationRangeBehavior {
  OpenOpen = 0
  ClosedClosed = 1
  OpenClosed = 2
  ClosedOpen = 3
} derive(Eq)

///|
/// Represents theme specific rendering styles for a {@link TextEditorDecorationType text editor decoration}.
pub type ThemableDecorationRenderOptions

///|
/// Represents theme specific rendering styles for {@link ThemableDecorationRenderOptions.before before} and
/// {@link ThemableDecorationRenderOptions.after after} the content of text decorations.
pub type ThemableDecorationAttachmentRenderOptions

///|
/// Represents render options for decoration instances. See {@link DecorationOptions.renderOptions}.
pub(all) struct DecorationInstanceRenderOptions {
  before : ThemableDecorationAttachmentRenderOptions?
  after : ThemableDecorationAttachmentRenderOptions?
  mut light : ThemableDecorationInstanceRenderOptions?
  mut dark : ThemableDecorationInstanceRenderOptions?
}

///|
/// Represents themable render options for decoration instances.
pub(all) struct ThemableDecorationInstanceRenderOptions {
  mut before : ThemableDecorationAttachmentRenderOptions?
  mut after : ThemableDecorationAttachmentRenderOptions?
}

///|
fn option_themable_decoration_attachment_render_options_to_js(
  value : ThemableDecorationAttachmentRenderOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) =>
      themable_decoration_attachment_render_options_to_js_ffi(value)
  }
}

///|
fn option_themable_decoration_render_options_to_js(
  value : ThemableDecorationRenderOptions?,
) -> JsValue {
  match value {
    None => JsValue::make(())
    Some(value) => themable_decoration_render_options_to_js_ffi(value)
  }
}

///|
pub fn ThemableDecorationAttachmentRenderOptions::new(
  content_text? : String,
  content_icon_path? : UriOrString,
  border? : String,
  border_color? : ColorValue,
  font_style? : String,
  font_weight? : String,
  text_decoration? : String,
  color? : ColorValue,
  background_color? : ColorValue,
  margin? : String,
  width? : String,
  height? : String,
) -> ThemableDecorationAttachmentRenderOptions {
  let content_icon_path_js = match content_icon_path {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  themable_decoration_attachment_render_options_ffi(
    option_to_js(content_text),
    content_icon_path_js,
    option_to_js(border),
    option_color_value_to_js(border_color),
    option_to_js(font_style),
    option_to_js(font_weight),
    option_to_js(text_decoration),
    option_color_value_to_js(color),
    option_color_value_to_js(background_color),
    option_to_js(margin),
    option_to_js(width),
    option_to_js(height),
  )
}

///|
pub fn ThemableDecorationRenderOptions::new(
  background_color? : ColorValue,
  outline? : String,
  outline_color? : ColorValue,
  outline_style? : String,
  outline_width? : String,
  border? : String,
  border_color? : ColorValue,
  border_radius? : String,
  border_spacing? : String,
  border_style? : String,
  border_width? : String,
  font_style? : String,
  font_weight? : String,
  text_decoration? : String,
  cursor? : String,
  color? : ColorValue,
  opacity? : String,
  letter_spacing? : String,
  gutter_icon_path? : UriOrString,
  gutter_icon_size? : String,
  overview_ruler_color? : ColorValue,
  before? : ThemableDecorationAttachmentRenderOptions,
  after? : ThemableDecorationAttachmentRenderOptions,
) -> ThemableDecorationRenderOptions {
  let gutter_icon_path_js = match gutter_icon_path {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  themable_decoration_render_options_ffi(
    option_color_value_to_js(background_color),
    option_to_js(outline),
    option_color_value_to_js(outline_color),
    option_to_js(outline_style),
    option_to_js(outline_width),
    option_to_js(border),
    option_color_value_to_js(border_color),
    option_to_js(border_radius),
    option_to_js(border_spacing),
    option_to_js(border_style),
    option_to_js(border_width),
    option_to_js(font_style),
    option_to_js(font_weight),
    option_to_js(text_decoration),
    option_to_js(cursor),
    option_color_value_to_js(color),
    option_to_js(opacity),
    option_to_js(letter_spacing),
    gutter_icon_path_js,
    option_to_js(gutter_icon_size),
    option_color_value_to_js(overview_ruler_color),
    option_themable_decoration_attachment_render_options_to_js(before),
    option_themable_decoration_attachment_render_options_to_js(after),
  )
}

///|
pub fn DecorationRenderOptions::new(
  background_color? : ColorValue,
  outline? : String,
  outline_color? : ColorValue,
  outline_style? : String,
  outline_width? : String,
  border? : String,
  border_color? : ColorValue,
  border_radius? : String,
  border_spacing? : String,
  border_style? : String,
  border_width? : String,
  font_style? : String,
  font_weight? : String,
  text_decoration? : String,
  cursor? : String,
  color? : ColorValue,
  opacity? : String,
  letter_spacing? : String,
  gutter_icon_path? : UriOrString,
  gutter_icon_size? : String,
  overview_ruler_color? : ColorValue,
  before? : ThemableDecorationAttachmentRenderOptions,
  after? : ThemableDecorationAttachmentRenderOptions,
  is_whole_line? : Bool,
  range_behavior? : DecorationRangeBehavior,
  overview_ruler_lane? : OverviewRulerLane,
  light? : ThemableDecorationRenderOptions,
  dark? : ThemableDecorationRenderOptions,
) -> DecorationRenderOptions {
  let gutter_icon_path_js = match gutter_icon_path {
    None => JsValue::make(())
    Some(value) => value.to_js()
  }
  decoration_render_options_ffi(
    option_color_value_to_js(background_color),
    option_to_js(outline),
    option_color_value_to_js(outline_color),
    option_to_js(outline_style),
    option_to_js(outline_width),
    option_to_js(border),
    option_color_value_to_js(border_color),
    option_to_js(border_radius),
    option_to_js(border_spacing),
    option_to_js(border_style),
    option_to_js(border_width),
    option_to_js(font_style),
    option_to_js(font_weight),
    option_to_js(text_decoration),
    option_to_js(cursor),
    option_color_value_to_js(color),
    option_to_js(opacity),
    option_to_js(letter_spacing),
    gutter_icon_path_js,
    option_to_js(gutter_icon_size),
    option_color_value_to_js(overview_ruler_color),
    option_themable_decoration_attachment_render_options_to_js(before),
    option_themable_decoration_attachment_render_options_to_js(after),
    option_to_js(is_whole_line),
    option_to_js(range_behavior),
    option_to_js(overview_ruler_lane),
    option_themable_decoration_render_options_to_js(light),
    option_themable_decoration_render_options_to_js(dark),
  )
}

///|
pub fn ThemableDecorationInstanceRenderOptions::new(
  before? : ThemableDecorationAttachmentRenderOptions,
  after? : ThemableDecorationAttachmentRenderOptions,
) -> ThemableDecorationInstanceRenderOptions {
  ThemableDecorationInstanceRenderOptions::{ before, after }
}

///|
pub fn DecorationInstanceRenderOptions::new(
  before? : ThemableDecorationAttachmentRenderOptions,
  after? : ThemableDecorationAttachmentRenderOptions,
  light? : ThemableDecorationInstanceRenderOptions,
  dark? : ThemableDecorationInstanceRenderOptions,
) -> DecorationInstanceRenderOptions {
  DecorationInstanceRenderOptions::{ before, after, light, dark }
}

///|
fn themable_decoration_instance_render_options_to_js(
  value : ThemableDecorationInstanceRenderOptions,
) -> JsValue {
  themable_decoration_instance_render_options_to_js_ffi(
    option_themable_decoration_attachment_render_options_to_js(value.before),
    option_themable_decoration_attachment_render_options_to_js(value.after),
  )
}

///|
fn decoration_instance_render_options_to_js(
  value : DecorationInstanceRenderOptions,
) -> JsValue {
  let light = match value.light {
    None => JsValue::make(())
    Some(options) => themable_decoration_instance_render_options_to_js(options)
  }
  let dark = match value.dark {
    None => JsValue::make(())
    Some(options) => themable_decoration_instance_render_options_to_js(options)
  }
  decoration_instance_render_options_to_js_ffi(
    option_themable_decoration_attachment_render_options_to_js(value.before),
    option_themable_decoration_attachment_render_options_to_js(value.after),
    light,
    dark,
  )
}

///|
pub fn DecorationOptions::new(
  range : Range,
  hover_message? : HoverMessage,
  render_options? : DecorationInstanceRenderOptions,
) -> DecorationOptions {
  let render_options_js = match render_options {
    None => JsValue::make(())
    Some(value) => decoration_instance_render_options_to_js(value)
  }
  decoration_options_ffi(
    range,
    option_hover_message_to_js(hover_message),
    render_options_js,
  )
}

///|

///|
extern "js" fn themable_decoration_attachment_render_options_ffi(
  content_text : JsValue,
  content_icon_path : JsValue,
  border : JsValue,
  border_color : JsValue,
  font_style : JsValue,
  font_weight : JsValue,
  text_decoration : JsValue,
  color : JsValue,
  background_color : JsValue,
  margin : JsValue,
  width : JsValue,
  height : JsValue,
) -> ThemableDecorationAttachmentRenderOptions =
  #| (contentText, contentIconPath, border, borderColor, fontStyle, fontWeight, textDecoration, color, backgroundColor, margin, width, height) => {
  #|   const options = {};
  #|   if (contentText !== undefined && contentText !== null) options.contentText = contentText;
  #|   if (contentIconPath !== undefined && contentIconPath !== null) options.contentIconPath = contentIconPath;
  #|   if (border !== undefined && border !== null) options.border = border;
  #|   if (borderColor !== undefined && borderColor !== null) options.borderColor = borderColor;
  #|   if (fontStyle !== undefined && fontStyle !== null) options.fontStyle = fontStyle;
  #|   if (fontWeight !== undefined && fontWeight !== null) options.fontWeight = fontWeight;
  #|   if (textDecoration !== undefined && textDecoration !== null) options.textDecoration = textDecoration;
  #|   if (color !== undefined && color !== null) options.color = color;
  #|   if (backgroundColor !== undefined && backgroundColor !== null) options.backgroundColor = backgroundColor;
  #|   if (margin !== undefined && margin !== null) options.margin = margin;
  #|   if (width !== undefined && width !== null) options.width = width;
  #|   if (height !== undefined && height !== null) options.height = height;
  #|   return options;
  #| }

///|
extern "js" fn themable_decoration_render_options_ffi(
  background_color : JsValue,
  outline : JsValue,
  outline_color : JsValue,
  outline_style : JsValue,
  outline_width : JsValue,
  border : JsValue,
  border_color : JsValue,
  border_radius : JsValue,
  border_spacing : JsValue,
  border_style : JsValue,
  border_width : JsValue,
  font_style : JsValue,
  font_weight : JsValue,
  text_decoration : JsValue,
  cursor : JsValue,
  color : JsValue,
  opacity : JsValue,
  letter_spacing : JsValue,
  gutter_icon_path : JsValue,
  gutter_icon_size : JsValue,
  overview_ruler_color : JsValue,
  before : JsValue,
  after : JsValue,
) -> ThemableDecorationRenderOptions =
  #| (backgroundColor, outline, outlineColor, outlineStyle, outlineWidth, border, borderColor, borderRadius, borderSpacing, borderStyle, borderWidth, fontStyle, fontWeight, textDecoration, cursor, color, opacity, letterSpacing, gutterIconPath, gutterIconSize, overviewRulerColor, before, after) => {
  #|   const options = {};
  #|   if (backgroundColor !== undefined && backgroundColor !== null) options.backgroundColor = backgroundColor;
  #|   if (outline !== undefined && outline !== null) options.outline = outline;
  #|   if (outlineColor !== undefined && outlineColor !== null) options.outlineColor = outlineColor;
  #|   if (outlineStyle !== undefined && outlineStyle !== null) options.outlineStyle = outlineStyle;
  #|   if (outlineWidth !== undefined && outlineWidth !== null) options.outlineWidth = outlineWidth;
  #|   if (border !== undefined && border !== null) options.border = border;
  #|   if (borderColor !== undefined && borderColor !== null) options.borderColor = borderColor;
  #|   if (borderRadius !== undefined && borderRadius !== null) options.borderRadius = borderRadius;
  #|   if (borderSpacing !== undefined && borderSpacing !== null) options.borderSpacing = borderSpacing;
  #|   if (borderStyle !== undefined && borderStyle !== null) options.borderStyle = borderStyle;
  #|   if (borderWidth !== undefined && borderWidth !== null) options.borderWidth = borderWidth;
  #|   if (fontStyle !== undefined && fontStyle !== null) options.fontStyle = fontStyle;
  #|   if (fontWeight !== undefined && fontWeight !== null) options.fontWeight = fontWeight;
  #|   if (textDecoration !== undefined && textDecoration !== null) options.textDecoration = textDecoration;
  #|   if (cursor !== undefined && cursor !== null) options.cursor = cursor;
  #|   if (color !== undefined && color !== null) options.color = color;
  #|   if (opacity !== undefined && opacity !== null) options.opacity = opacity;
  #|   if (letterSpacing !== undefined && letterSpacing !== null) options.letterSpacing = letterSpacing;
  #|   if (gutterIconPath !== undefined && gutterIconPath !== null) options.gutterIconPath = gutterIconPath;
  #|   if (gutterIconSize !== undefined && gutterIconSize !== null) options.gutterIconSize = gutterIconSize;
  #|   if (overviewRulerColor !== undefined && overviewRulerColor !== null) options.overviewRulerColor = overviewRulerColor;
  #|   if (before !== undefined && before !== null) options.before = before;
  #|   if (after !== undefined && after !== null) options.after = after;
  #|   return options;
  #| }

///|
extern "js" fn decoration_render_options_ffi(
  background_color : JsValue,
  outline : JsValue,
  outline_color : JsValue,
  outline_style : JsValue,
  outline_width : JsValue,
  border : JsValue,
  border_color : JsValue,
  border_radius : JsValue,
  border_spacing : JsValue,
  border_style : JsValue,
  border_width : JsValue,
  font_style : JsValue,
  font_weight : JsValue,
  text_decoration : JsValue,
  cursor : JsValue,
  color : JsValue,
  opacity : JsValue,
  letter_spacing : JsValue,
  gutter_icon_path : JsValue,
  gutter_icon_size : JsValue,
  overview_ruler_color : JsValue,
  before : JsValue,
  after : JsValue,
  is_whole_line : JsValue,
  range_behavior : JsValue,
  overview_ruler_lane : JsValue,
  light : JsValue,
  dark : JsValue,
) -> DecorationRenderOptions =
  #| (backgroundColor, outline, outlineColor, outlineStyle, outlineWidth, border, borderColor, borderRadius, borderSpacing, borderStyle, borderWidth, fontStyle, fontWeight, textDecoration, cursor, color, opacity, letterSpacing, gutterIconPath, gutterIconSize, overviewRulerColor, before, after, isWholeLine, rangeBehavior, overviewRulerLane, light, dark) => {
  #|   const options = {};
  #|   if (backgroundColor !== undefined && backgroundColor !== null) options.backgroundColor = backgroundColor;
  #|   if (outline !== undefined && outline !== null) options.outline = outline;
  #|   if (outlineColor !== undefined && outlineColor !== null) options.outlineColor = outlineColor;
  #|   if (outlineStyle !== undefined && outlineStyle !== null) options.outlineStyle = outlineStyle;
  #|   if (outlineWidth !== undefined && outlineWidth !== null) options.outlineWidth = outlineWidth;
  #|   if (border !== undefined && border !== null) options.border = border;
  #|   if (borderColor !== undefined && borderColor !== null) options.borderColor = borderColor;
  #|   if (borderRadius !== undefined && borderRadius !== null) options.borderRadius = borderRadius;
  #|   if (borderSpacing !== undefined && borderSpacing !== null) options.borderSpacing = borderSpacing;
  #|   if (borderStyle !== undefined && borderStyle !== null) options.borderStyle = borderStyle;
  #|   if (borderWidth !== undefined && borderWidth !== null) options.borderWidth = borderWidth;
  #|   if (fontStyle !== undefined && fontStyle !== null) options.fontStyle = fontStyle;
  #|   if (fontWeight !== undefined && fontWeight !== null) options.fontWeight = fontWeight;
  #|   if (textDecoration !== undefined && textDecoration !== null) options.textDecoration = textDecoration;
  #|   if (cursor !== undefined && cursor !== null) options.cursor = cursor;
  #|   if (color !== undefined && color !== null) options.color = color;
  #|   if (opacity !== undefined && opacity !== null) options.opacity = opacity;
  #|   if (letterSpacing !== undefined && letterSpacing !== null) options.letterSpacing = letterSpacing;
  #|   if (gutterIconPath !== undefined && gutterIconPath !== null) options.gutterIconPath = gutterIconPath;
  #|   if (gutterIconSize !== undefined && gutterIconSize !== null) options.gutterIconSize = gutterIconSize;
  #|   if (overviewRulerColor !== undefined && overviewRulerColor !== null) options.overviewRulerColor = overviewRulerColor;
  #|   if (before !== undefined && before !== null) options.before = before;
  #|   if (after !== undefined && after !== null) options.after = after;
  #|   if (isWholeLine !== undefined && isWholeLine !== null) options.isWholeLine = isWholeLine;
  #|   if (rangeBehavior !== undefined && rangeBehavior !== null) options.rangeBehavior = rangeBehavior;
  #|   if (overviewRulerLane !== undefined && overviewRulerLane !== null) options.overviewRulerLane = overviewRulerLane;
  #|   if (light !== undefined && light !== null) options.light = light;
  #|   if (dark !== undefined && dark !== null) options.dark = dark;
  #|   return options;
  #| }

///|
extern "js" fn themable_decoration_instance_render_options_to_js_ffi(
  before : JsValue,
  after : JsValue,
) -> JsValue =
  #| (before, after) => {
  #|   const options = {};
  #|   if (before !== undefined && before !== null) options.before = before;
  #|   if (after !== undefined && after !== null) options.after = after;
  #|   return options;
  #| }

///|
extern "js" fn decoration_instance_render_options_to_js_ffi(
  before : JsValue,
  after : JsValue,
  light : JsValue,
  dark : JsValue,
) -> JsValue =
  #| (before, after, light, dark) => {
  #|   const options = {};
  #|   if (before !== undefined && before !== null) options.before = before;
  #|   if (after !== undefined && after !== null) options.after = after;
  #|   if (light !== undefined && light !== null) options.light = light;
  #|   if (dark !== undefined && dark !== null) options.dark = dark;
  #|   return options;
  #| }

///|
extern "js" fn decoration_options_ffi(
  range : Range,
  hover_message : JsValue,
  render_options : JsValue,
) -> DecorationOptions =
  #| (range, hoverMessage, renderOptions) => {
  #|   const options = { range };
  #|   if (hoverMessage !== undefined && hoverMessage !== null) options.hoverMessage = hoverMessage;
  #|   if (renderOptions !== undefined && renderOptions !== null) options.renderOptions = renderOptions;
  #|   return options;
  #| }

///|
extern "js" fn themable_decoration_attachment_render_options_to_js_ffi(
  value : ThemableDecorationAttachmentRenderOptions,
) -> JsValue =
  #| (value) => value

///|
extern "js" fn themable_decoration_render_options_to_js_ffi(
  value : ThemableDecorationRenderOptions,
) -> JsValue =
  #| (value) => value
