class ApplicationPolicy < ActionPolicy::Base
  def permission
    @permission ||= case record
    when Class
      Access::Model.new(user, record)
    else
      Access::Model.new(user, record.class.name)
    end
  end

  private :permission
end
