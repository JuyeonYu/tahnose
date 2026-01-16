module KeywordsHelper
  # pub_date: String like "Fri, 16 Jan 2026 13:00:00 +0900"
  def relative_pub_date(pub_date)
    return "" if pub_date.blank?

    time = Time.zone.parse(pub_date.to_s) rescue nil
    return "" unless time

    diff = (Time.zone.now - time).to_i
    diff = 0 if diff.negative?

    minutes = diff / 60
    return "최근" if minutes <= 1
    return "#{minutes}분전" if minutes < 60

    hours = minutes / 60
    return "#{hours}시간전" if hours < 24

    days = hours / 24
    return "#{days}일전" if days < 7

    time.strftime("%Y.%m.%d")
  end

    def render_article_html(text)
    sanitize(
      CGI.unescapeHTML(text.to_s),
      tags: %w[b strong em br],
      attributes: []
    )
  end

end
