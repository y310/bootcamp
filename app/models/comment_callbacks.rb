# frozen_string_literal: true

class CommentCallbacks
  def before_save(comment)
    notify_mention(comment) if comment.new_mentions?
  end

  def after_create(comment)
    if comment.sender != comment.reciever
      notify_comment(comment)
    end

    notify_admin(comment)
  end

  private
    def notify_mention(comment)
      comment.new_mentions.each do |mention|
        reciever = User.find_by(login_name: mention)
        if reciever && comment.sender != reciever
          Notification.mentioned(comment, reciever)
        end
      end
    end

    def notify_comment(comment)
      Notification.came_comment(
        comment,
        comment.reciever,
        "#{comment.sender.login_name}さんからコメントが届きました。"
      )
    end

    def notify_admin(comment)
      return false if comment.commentable.class != Product

      User.admins.where.not(id: comment.user.id).each do |user|
        Notification.came_comment(
          comment,
          user,
          "#{comment.sender.login_name}さんが提出物にコメントしました。"
        )
      end
    end
end
