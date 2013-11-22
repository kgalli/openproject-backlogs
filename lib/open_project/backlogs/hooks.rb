#-- copyright
# OpenProject Backlogs Plugin
#
# Copyright (C)2013 the OpenProject Foundation (OPF)
# Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
# Copyright (C)2010-2011 friflaj
# Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
# Copyright (C)2009-2010 Mark Maglana
# Copyright (C)2009 Joe Heck, Nate Lowrie
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 3.
#
# OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
# The copyright follows:
# Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
# Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module OpenProject::Backlogs::Hooks
  class LayoutHook < Redmine::Hook::ViewListener
    include RbCommonHelper

    # This ought to be view_work_packages_sidebar_queries_bottom, but the entire
    # queries toolbar is disabled if you don't have custom queries
    def view_work_packages_sidebar_planning_bottom(context={ })
      locals = {}
      locals[:sprints] = context[:project] ? Sprint.open_sprints(context[:project]) : []
      locals[:project] = context[:project]
      locals[:sprint] = nil
      locals[:webcal] = (context[:request].ssl? ? 'webcals' : 'webcal')

      return '' unless locals[:project]
      return '' if locals[:project].blank?
      return '' unless locals[:project].module_enabled?('backlogs')

      user = User.find_by_id(context[:request].session[:user_id])
      locals[:key] = user ? user.api_key : nil

      q = context[:request].session[:query]
      if q && q[:filters]
        sprint = q[:filters].detect{|f| f.field == :fixed_version_id}
        if sprint && sprint[:operator] == '=' && sprint[:values].size == 1
          locals[:sprint] = Sprint.find_by_id(sprint[:values][0])
        end
      end

      context[:controller].send(:render_to_string, {
          :partial => 'shared/view_work_packages_sidebar',
          :locals => locals
      })
    end

    def view_work_packages_show_details_bottom(context = {})
      work_package = context[:issue]

      return '' unless work_package.backlogs_enabled?
      return '' if context[:from] == 'OpenProject::Backlogs::WorkPackageView::FieldsParagraph'


      snippet = ''

      if work_package.is_story?
        snippet += %Q{
          <tr>
            <th class="story-points">#{WorkPackage.human_attribute_name(:story_points)}:</th>
            <td class="story-points">#{work_package.story_points || '-'}</td>
          </tr>
        }
      end
      snippet += %Q{
        <tr>
          <th class="remaining_hours">#{WorkPackage.human_attribute_name(:remaining_hours)}:</th>
          <td class="remaining_hours">#{l_hours(work_package.remaining_hours)}</td>
        </tr>
      }

      snippet
    end

    def view_work_packages_form_details_bottom(context = {})
      snippet = ''
      work_package = context[:issue]

      return '' unless work_package.backlogs_enabled?

      snippet << %(<p>)
      snippet << %(<div id="backlogs-attributes" class="attributes">)
      snippet << %(<div class="splitcontentleft">)

      if work_package.is_story?
        snippet << '<p>'
        snippet << context[:form].text_field(:story_points, :size => 3)
        snippet << '</p>'

        if work_package.descendants.length != 0

          snippet << javascript_tag(<<-JS)
            (function($) {
              $(document).ready(function() {
                $('#issue_estimated_hours').attr('disabled', 'disabled');
                $('#issue_remaining_hours').attr('disabled', 'disabled');
                $('#issue_done_ratio').attr('disabled', 'disabled');
                $('#issue_start_date').parent().hide();
                $('#issue_due_date').parent().hide();
              });
            }(jQuery))
          JS
        end
      end

      snippet << '<p>'
      snippet << context[:form].text_field(:remaining_hours, :size => 3)
      snippet << ' '
      snippet << l(:label_hours)
      snippet << '</p>'

      params = context[:controller].params
      if work_package.is_story? && params[:copy_from]
        snippet << "<p><label for='link_to_original'>#{l(:rb_label_link_to_original)}</label>"
        snippet << "#{check_box_tag('link_to_original', params[:copy_from], true)}</p>"

        snippet << "<p><label>#{l(:rb_label_copy_tasks)}</label>"
        snippet << "#{radio_button_tag('copy_tasks', 'open:' + params[:copy_from], true)} #{l(:rb_label_copy_tasks_open)}<br />"
        snippet << "#{radio_button_tag('copy_tasks', 'none', false)} #{l(:rb_label_copy_tasks_none)}<br />"
        snippet << "#{radio_button_tag('copy_tasks', 'all:' + params[:copy_from], false)} #{l(:rb_label_copy_tasks_all)}</p>"
      end

      snippet << %(</div>) * 2
      snippet << %(</p>)

      snippet
    end

    def view_versions_show_bottom(context={ })
      version = context[:version]
      project = version.project

      return '' unless project.module_enabled? 'backlogs'

      snippet = ''

      if User.current.allowed_to?(:edit_wiki_pages, project)
        snippet += '<span id="edit_wiki_page_action">'
        snippet += link_to l(:button_edit_wiki), {:controller => '/rb_wikis', :action => 'edit', :project_id => project.id, :sprint_id => version.id }, :class => 'icon icon-edit'
        snippet += '</span>'

        # This wouldn't be necesary if the schedules plugin didn't disable the
        # contextual hook
        snippet += javascript_tag(<<-JS)
          (function ($) {
            $(document).ready(function() {
              $('#edit_wiki_page_action').detach().appendTo("div.contextual");
            });
          }(jQuery))
        JS
      end
    end

    def view_my_account(context={ })
      return context[:controller].send(:render_to_string, {
          :partial => 'shared/view_my_account',
          :locals => {:user => context[:user], :color => context[:user].backlogs_preference(:task_color), :versions_default_fold_state => context[:user].backlogs_preference(:versions_default_fold_state) }
        })
    end

    def controller_work_package_new_after_save(context={ })
      params = context[:params]
      work_package = context[:work_package]

      return unless work_package.backlogs_enabled?

      if work_package.is_story?
        if params[:link_to_original]
          rel = Relation.new

          rel.from_id = Integer(params[:link_to_original])
          rel.to_id = work_package.id
          rel.relation_type = Relation::TYPE_RELATES
          rel.save
        end

        if params[:copy_tasks]
          params[:copy_tasks] += ':' if params[:copy_tasks] !~ /:/
          action, id = *(params[:copy_tasks].split(/:/))

          story = (id == '' ? nil : Story.find(Integer(id)))

          if ! story.nil? && action != 'none'
            tasks = story.tasks
            case action
              when 'open'
                tasks = tasks.select{|t| !t.closed?}
              when 'all', 'none'
                #
              else
                raise "Unexpected value #{params[:copy_tasks]}"
            end

            tasks.each {|t|
              nt = Task.new
              nt.copy_from(t)
              nt.parent_id = work_package.id
              nt.save
            }
          end
        end
      end
    end

    # Renders story_points in v1 api#index
    #
    # Context:
    # * :api => Current api instance
    # * :issue => issue to render
    #
    def api_issue_index_attributes(context={})
      return unless context[:api] && context[:issue]
      context[:api].story_points context[:issue].story_points
    end
  end
end
