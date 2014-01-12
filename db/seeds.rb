# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

## Create constraint types
@constraint_type_relation = ConstraintType.create(:name => "End-Start")
@constraint_type_start = ConstraintType.create(:name => "Start")
@constraint_type_end = ConstraintType.create(:name => "End")

## Machines/Resources
@machine1 = Resource.find_or_create_by_name(:name => "Machine 1")
@machine1.capacity = 1
@machine1.steps_per_time_unit = 1
@machine1.save(:validate => false)

@machine2 = Resource.find_or_create_by_name(:name => "Machine 2")
@machine2.capacity = 1
@machine2.steps_per_time_unit = 2
@machine2.save(:validate => false)

@machine3 = Resource.find_or_create_by_name(:name => "Machine 3")
@machine3.capacity = 1
@machine3.steps_per_time_unit = 1
@machine3.save(:validate => false)

## Subjobs
# Start
@subjob_start = Subjob.new
@subjob_start.name = "Subjob Start"
@subjob_start.number_of_steps = 0
@subjob_start.save(:validate => false)

# 1,1
@subjob11 = Subjob.new
@subjob11.name = "Subjob 1,1"
@subjob11.resources << @machine1
@subjob11.resources << @machine2
@subjob11.number_of_steps = 4
@subjob11.save(:validate => false)

# 1,2
@subjob12 = Subjob.new
@subjob12.name = "Subjob 1,2"
@subjob12.resources << @machine2
@subjob12.number_of_steps = 4
@subjob12.save(:validate => false)

# 1,3
@subjob13 = Subjob.new
@subjob13.name = "Subjob 1,3"
@subjob13.resources << @machine3
@subjob13.number_of_steps = 2
@subjob13.save(:validate => false)

# 2,1
@subjob21 = Subjob.new
@subjob21.name = "Subjob 2,1"
@subjob21.resources << @machine2
@subjob21.number_of_steps = 3
@subjob21.save(:validate => false)

# 2,2
@subjob22 = Subjob.new
@subjob22.name = "Subjob 2,2"
@subjob22.resources << @machine1
@subjob22.number_of_steps = 1
@subjob22.save(:validate => false)

# 3,1
@subjob31 = Subjob.new
@subjob31.name = "Subjob 3,1"
@subjob31.resources << @machine1
@subjob31.number_of_steps = 2
@subjob31.save(:validate => false)

# 3,2
@subjob32 = Subjob.new
@subjob32.name = "Subjob 3,2"
@subjob32.resources << @machine3
@subjob32.number_of_steps = 3
@subjob32.save(:validate => false)

# End
@subjob_end = Subjob.new
@subjob_end.name = "Subjob end"
@subjob_end.number_of_steps = 0
@subjob_end.save(:validate => false)

## Constraints
# Start
@constraint_start_11 = Constraint.create(:constraint_type => @constraint_type_start, :subjob_one => @subjob_start, :subjob_two => @subjob11)
@constraint_start_21 = Constraint.create(:constraint_type => @constraint_type_start, :subjob_one => @subjob_start, :subjob_two => @subjob21)
@constraint_start_31 = Constraint.create(:constraint_type => @constraint_type_start, :subjob_one => @subjob_start, :subjob_two => @subjob31)

# Job 1
@constraint_11_12 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob11, :subjob_two => @subjob12)
@constraint_12_13 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob12, :subjob_two => @subjob13)

# Job 2
@constraint_21_22 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob21, :subjob_two => @subjob22)

# Job 3
@constraint_31_32 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob31, :subjob_two => @subjob32)

# End
@constraint_13_end = Constraint.create(:constraint_type => @constraint_type_end, :subjob_one => @subjob13, :subjob_two => @subjob_end)
@constraint_22_end = Constraint.create(:constraint_type => @constraint_type_end, :subjob_one => @subjob22, :subjob_two => @subjob_end)
@constraint_32_end = Constraint.create(:constraint_type => @constraint_type_end, :subjob_one => @subjob32, :subjob_two => @subjob_end)

#Schleife für Test
@constraint_12_22 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob12, :subjob_two => @subjob22)
#@constraint_22_11 = Constraint.create(:constraint_type => @constraint_type_relation, :subjob_one => @subjob22, :subjob_two => @subjob11)

# Add constraints to subjobs

## Jobs
# Job start
#@job_start = Job.new
#@job_start.name = "Job Start"
#@job_start.subjobs << @subjob_start
#@job_start.save(:validate => false)

# Job 1
@job1 = Job.new
@job1.name = "Job 1"
@job1.subjobs << @subjob11
@job1.subjobs << @subjob12
@job1.subjobs << @subjob13
@job1.save(:validate => false)

# Job 2
@job2 = Job.new
@job2.name = "Job 2"
@job2.subjobs << @subjob21
@job2.subjobs << @subjob22
@job2.save(:validate => false)

# Job 3
@job3 = Job.new
@job3.name = "Job 3"
@job3.subjobs << @subjob31
@job3.subjobs << @subjob32
@job3.save(:validate => false)

# Job end
#@job_end = Job.new
#@job_end.name = "Job End"
#@job_end.subjobs << @subjob_end
#@job_end.save(:validate => false)