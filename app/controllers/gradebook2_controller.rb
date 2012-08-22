class Gradebook2Controller < ApplicationController
  before_filter :require_context
  add_crumb("Gradebook") { |c| c.send :named_context_url, c.instance_variable_get("@context"), :context_grades_url }
  before_filter { |c| c.active_tab = "grades" }

  def show
    if authorized_action(@context, @current_user, :view_all_grades)
        js_env  :GRADEBOOK_OPTIONS => {
          :chunk_size => Setting.get_cached('gradebook2.submissions_chunk_size', '35').to_i,
          :assignment_groups_url => api_v1_course_assignment_groups_url(@context, :include => [:assignments]),
          :sections_url => api_v1_course_sections_url(@context),
          :students_url => api_v1_course_enrollments_url(@context, :include => [:avatar_url], :type => ['StudentEnrollment', 'StudentViewEnrollment'], :per_page => 100),
          :submissions_url => api_v1_course_student_submissions_url(@context, :grouped => '1'),
          :change_grade_url => api_v1_course_assignment_submission_url(@context, ":assignment", ":submission"),
          :context_url => named_context_url(@context, :context_url),
          :download_assignment_submissions_url => named_context_url(@context, :context_assignment_submissions_url, "{{ assignment_id }}", :zip => 1),
          :re_upload_submissions_url => named_context_url(@context, :context_gradebook_submissions_upload_url, "{{ assignment_id }}"),
          :context_id => @context.id,
          :context_code => @context.asset_string,
          :group_weighting_scheme => @context.group_weighting_scheme,
          :show_concluded_enrollments => @context.completed?,
          :grading_standard =>  @context.grading_standard_enabled? && (@context.grading_standard.try(:data) || GradingStandard.default_grading_standard)
        }
    end
  end
end
