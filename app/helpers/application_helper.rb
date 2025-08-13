module ApplicationHelper
  def entity_type_label(entity_type)
    entity_type.titleize
  end

  def entity_type_icon_class(entity_type)
    case entity_type
    when 'person'
      'text-blue-600'
    when 'place'
      'text-green-600'
    when 'thing'
      'text-purple-600'
    else
      'text-gray-600'
    end
  end

  def entity_type_bg_class(entity_type)
    case entity_type
    when 'person'
      'bg-blue-100'
    when 'place'
      'bg-green-100'
    when 'thing'
      'bg-purple-100'
    else
      'bg-gray-100'
    end
  end
end
