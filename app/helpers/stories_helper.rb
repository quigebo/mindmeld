module StoriesHelper
  def people_color_scheme
    {
      bg_light: "bg-blue-100",
      icon: "text-blue-600",
      card_bg: "bg-blue-50",
      card_hover: "bg-blue-100",
      border: "border-blue-200",
      text_primary: "text-blue-900",
      text_secondary: "text-blue-600",
      badge_bg: "bg-blue-100",
      badge_text: "text-blue-800"
    }
  end

  def places_color_scheme
    {
      bg_light: "bg-green-100",
      icon: "text-green-600",
      card_bg: "bg-green-50",
      card_hover: "bg-green-100",
      border: "border-green-200",
      text_primary: "text-green-900",
      text_secondary: "text-green-600",
      badge_bg: "bg-green-100",
      badge_text: "text-green-800"
    }
  end

  def things_color_scheme
    {
      bg_light: "bg-purple-100",
      icon: "text-purple-600",
      card_bg: "bg-purple-50",
      card_hover: "bg-purple-100",
      border: "border-purple-200",
      text_primary: "text-purple-900",
      text_secondary: "text-purple-600",
      badge_bg: "bg-purple-100",
      badge_text: "text-purple-800"
    }
  end

  # Predefined icon paths for entity types
  def people_icon_path
    "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
  end

  def places_icon_path
    "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z"
  end

  def things_icon_path
    "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
  end
end
