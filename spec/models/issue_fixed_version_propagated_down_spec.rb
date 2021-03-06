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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WorkPackage, "changing a story's fixed_version changes the fixed_version of all it's tasks (and the tasks beyond)" do
  let(:type_feature) { FactoryGirl.build(:type_feature) }
  let(:type_task) { FactoryGirl.build(:type_task) }
  let(:type_bug) { FactoryGirl.build(:type_bug) }
  let(:version1) { project.versions.first }
  let(:version2) { project.versions.last }
  let(:role) { FactoryGirl.build(:role) }
  let(:user) { FactoryGirl.build(:user) }
  let(:issue_priority) { FactoryGirl.build(:priority) }
  let(:status) { FactoryGirl.build(:status, :name => "status 1", :is_default => true) }

  let(:project) do
    p = FactoryGirl.build(:project, :members => [FactoryGirl.build(:member,
                                                           :principal => user,
                                                           :roles => [role])],
                                :types => [type_feature, type_task, type_bug])

    p.versions << FactoryGirl.build(:version, :name => "Version1", :project => p)
    p.versions << FactoryGirl.build(:version, :name => "Version2", :project => p)

    p
  end


  let(:story) do
    story = FactoryGirl.build(:work_package,
                              :subject => "Story",
                              :project => project,
                              :type => type_feature,
                              :fixed_version => version1,
                              :status => status,
                              :author => user,
                              :priority => issue_priority)
    story
  end

  let(:story2) do
    story = FactoryGirl.build(:work_package,
                              :subject => "Story2",
                              :project => project,
                              :type => type_feature,
                              :fixed_version => version1,
                              :status => status,
                              :author => user,
                              :priority => issue_priority)
    story
  end

  let(:story3) do
    story = FactoryGirl.build(:work_package,
                              :subject => "Story3",
                              :project => project,
                              :type => type_feature,
                              :fixed_version => version1,
                              :status => status,
                              :author => user,
                              :priority => issue_priority)
    story
  end

  let(:task) { FactoryGirl.build(:work_package,
                             :subject => "Task",
                             :type => type_task,
                             :fixed_version => version1,
                             :project => project,
                             :status => status,
                             :author => user,
                             :priority => issue_priority) }

  let(:task2) { FactoryGirl.build(:work_package,
                              :subject => "Task2",
                              :type => type_task,
                              :fixed_version => version1,
                              :project => project,
                              :status => status,
                              :author => user,
                              :priority => issue_priority) }

  let(:task3) { FactoryGirl.build(:work_package,
                              :subject => "Task3",
                              :type => type_task,
                              :fixed_version => version1,
                              :project => project,
                              :status => status,
                              :author => user,
                              :priority => issue_priority) }

  let(:task4) { FactoryGirl.build(:work_package,
                              :subject => "Task4",
                              :type => type_task,
                              :fixed_version => version1,
                              :project => project,
                              :status => status,
                              :author => user,
                              :priority => issue_priority) }

  let(:task5) { FactoryGirl.build(:work_package,
                              :subject => "Task5",
                              :type => type_task,
                              :fixed_version => version1,
                              :project => project,
                              :status => status,
                              :author => user,
                              :priority => issue_priority) }

  let(:task6) { FactoryGirl.build(:work_package,
                              :subject => "Task6",
                              :type => type_task,
                              :fixed_version => version1,
                              :project => project,
                              :status => status,
                              :author => user,
                              :priority => issue_priority) }

  let(:bug) { FactoryGirl.build(:work_package,
                            :subject => "Bug",
                            :type => type_bug,
                            :fixed_version => version1,
                            :project => project,
                            :status => status,
                            :author => user,
                            :priority => issue_priority) }

  let(:bug2) { FactoryGirl.build(:work_package,
                             :subject => "Bug2",
                             :type => type_bug,
                             :fixed_version => version1,
                             :project => project,
                             :status => status,
                             :author => user,
                             :priority => issue_priority) }

  let(:bug3) { FactoryGirl.build(:work_package,
                             :subject => "Bug3",
                             :type => type_bug,
                             :fixed_version => version1,
                             :project => project,
                             :status => status,
                             :author => user,
                             :priority => issue_priority) }

  before(:each) do
    project.save!

    Setting.stub(:plugin_openproject_backlogs).and_return({"points_burn_direction" => "down",
                                                            "wiki_template"         => "",
                                                            "card_spec"             => "Sattleford VM-5040",
                                                            "story_types"           => [type_feature.id],
                                                            "task_type"             => type_task.id.to_s})
  end

  def standard_child_layout
    # Layout is
    # child
    # -> task3
    # -> task4
    # -> bug3
    #   -> task5
    # -> story3
    #   -> task6
    task3.parent_id = child.id
    task3.save!
    task4.parent_id = child.id
    task4.save!
    bug3.parent_id = child.id
    bug3.save!
    story3.parent_id = child.id
    story3.save!

    task5.parent_id = bug3.id
    task5.save!
    task6.parent_id = story3.id
    task6.save!

    child.reload
  end


  describe "WHEN changing fixed_version" do

    shared_examples_for "changing parent's fixed_version changes child's fixed version" do

      it "SHOULD change the child's fixed version to the parent's fixed version" do
        subject.save!
        child.parent_id = subject.id
        child.save!

        standard_child_layout

        subject.reload

        subject.fixed_version = version2
        subject.save!

        # Because of performance, these assertions are all in one it statement
        child.reload.fixed_version.should eql version2
        task3.reload.fixed_version.should eql version2
        task4.reload.fixed_version.should eql version2
        bug3.reload.fixed_version.should eql version1
        story3.reload.fixed_version.should eql version1
        task5.reload.fixed_version.should eql version1
        task6.reload.fixed_version.should eql version1
      end
    end

    shared_examples_for "changing parent's fixed_version does not change child's fixed_version" do

      it "SHOULD keep the child's version" do
        subject.save!
        child.parent_id = subject.id
        child.save!

        standard_child_layout

        subject.reload

        subject.fixed_version = version2
        subject.save!

        # Because of performance, these assertions are all in one it statement
        child.reload.fixed_version.should eql version1
        task3.reload.fixed_version.should eql version1
        task4.reload.fixed_version.should eql version1
        bug3.reload.fixed_version.should eql version1
        story3.reload.fixed_version.should eql version1
        task5.reload.fixed_version.should eql version1
        task6.reload.fixed_version.should eql version1
      end
    end

    describe "WITH backlogs enabled" do
      before(:each) do
        project.enabled_module_names += ["backlogs"]
      end

      describe "WITH a story" do
        subject { story }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing parent's fixed_version changes child's fixed version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a story as a child" do
          let(:child) { story2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end

      describe "WITH a task (impediment) without a parent" do
        subject { task }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing parent's fixed_version changes child's fixed version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end

      describe "WITH a non backlogs work_package" do
        subject { bug }

        describe "WITH a task as child" do
          let(:child) { task }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a story as a child" do
          let(:child) { story }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end
    end

    describe "WITH backlogs disabled" do
      before(:each) do
        project.enabled_module_names = project.enabled_module_names.find_all{|n| n != "backlogs" }
      end

      describe "WITH a story" do
        subject { story }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a story as a child" do
          let(:child) { story2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end

      describe "WITH a task" do
        before(:each) do
          bug2.save!
          task.parent_id = bug2.id # so that it is considered a task
          task.save!
        end

        subject { task }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end

      describe "WITH a task (impediment) without a parent" do
        subject { task }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end

      describe "WITH a non backlogs work_package" do
        subject { bug }

        describe "WITH a task as child" do
          let(:child) { task }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a non backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end

        describe "WITH a story as a child" do
          let(:child) { story }

          it_should_behave_like "changing parent's fixed_version does not change child's fixed_version"
        end
      end
    end
  end

  describe "WHEN changing the parent_id" do
    shared_examples_for "changing the child's parent_issue to the parent changes child's fixed version" do

      it "SHOULD change the child's fixed version to the parent's fixed version" do
        child.save!
        standard_child_layout

        parent.fixed_version = version2
        parent.save!
        child.parent_id = parent.id
        child.save!

        # Because of performance, these assertions are all in one it statement
        child.reload.fixed_version.should eql version2
        task3.reload.fixed_version.should eql version2
        task4.reload.fixed_version.should eql version2
        bug3.reload.fixed_version.should eql version1
        story3.reload.fixed_version.should eql version1
        task5.reload.fixed_version.should eql version1
        task6.reload.fixed_version.should eql version1
      end
    end

    shared_examples_for "changing the child's parent to the parent leaves child's fixed version" do

      it "SHOULD keep the child's version" do
        child.save!
        standard_child_layout

        parent.fixed_version = version2
        parent.save!
        child.parent_id = parent.id
        child.save!

        # Because of performance, these assertions are all in one it statement
        child.reload.fixed_version.should eql version1
        task3.reload.fixed_version.should eql version1
        task4.reload.fixed_version.should eql version1
        bug3.reload.fixed_version.should eql version1
        story3.reload.fixed_version.should eql version1
        task5.reload.fixed_version.should eql version1
        task6.reload.fixed_version.should eql version1
      end
    end

    describe "WITH backogs enabled" do
      before(:each) do
        story.project.enabled_module_names += ["backlogs"]
      end

      describe "WITH a story as parent" do
        let(:parent) { story }

        describe "WITH a story as child" do
          let(:child) { story2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing the child's parent_issue to the parent changes child's fixed version"
        end

        describe "WITH a non-backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end
      end

      describe "WITH a story as parent
                WITH the story having a non backlogs work_package as parent
                WITH a task as child" do
        before do
          bug2.save!
          story.parent_id = bug2.id
          story.save!
        end

        let(:parent) { story }
        let(:child) { task2 }

        it_should_behave_like "changing the child's parent_issue to the parent changes child's fixed version"
      end

      describe "WITH a task as parent" do
        before(:each) do
          story.save!
          task.parent_id = story.id
          task.save!
          story.reload
          task.reload
        end

        # Needs to be the story because it is not possible to change a task's
        # 'fixed_version_id'
        let(:parent) { story }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing the child's parent_issue to the parent changes child's fixed version"
        end

        describe "WITH a non-backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end
      end

      describe "WITH an impediment (task) as parent" do
        let(:parent) { task }

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing the child's parent_issue to the parent changes child's fixed version"
        end

        describe "WITH a non-backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end
      end

      describe "WITH a non-backlogs work_package as parent" do
        let(:parent) { bug }

        describe "WITH a story as child" do
          let(:child) { story2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end

        describe "WITH a task as child" do
          let(:child) { task2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end

        describe "WITH a non-backlogs work_package as child" do
          let(:child) { bug2 }

          it_should_behave_like "changing the child's parent to the parent leaves child's fixed version"
        end
      end
    end
  end
end
