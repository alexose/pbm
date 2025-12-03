class UserSubmissionsController < ApplicationController
  has_scope :region

  def list_within_range
    bounds = [ params[:boundsData][:sw][:lat], params[:boundsData][:sw][:lng],
               params[:boundsData][:ne][:lat], params[:boundsData][:ne][:lng] ]

    submission_types = if params[:submission_type].present?
                         params[:submission_type]
                       else
                         UserSubmission::ACTIVITY_SUBMISSION_TYPES
                       end

    user_submissions = UserSubmission.with_coordinates
                                     .where(
                                       submission_type: submission_types,
                                       created_at: UserSubmission::ACTIVITY_START_DATE..Date.today.end_of_day,
                                       deleted_at: nil
                                     )
                                     .within_bounding_box(bounds)
                                     .order("created_at DESC")
                                     .limit(2000)
    @pagy, sorted_submissions = pagy(user_submissions, items: 10, limit_extra: false)
    render partial: "maps/activity", locals: { sorted_submissions: sorted_submissions, pagy: @pagy, submission_types: submission_types }
  end
end
