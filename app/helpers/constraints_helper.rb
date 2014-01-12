module ConstraintsHelper
  #Helper mit rekursivem Suchen von Schleifen, ausgehend von 1 Subjob
  def search_cycles(subjob, subjobs=[], exclude=[])
    logger.debug "Handling subjob: #{subjob.name}"
    logger.debug "Exclude list contains # items: #{exclude.size}"
    
    #Pr¸fe, ob gleicher Subjob bereits einmal gefunden (-> Schleife = Abbruchbedingung)
    if subjobs.include?(subjob)
      logger.debug "Current subjob seems to build a cycle #{subjob.name}"
      return false
    end
    #Wenn keine Schleife gefunden, suche weiter
    if not subjob.is_end_subjob? and not subjobs.include?(subjob) and not exclude.include?(subjob)
      subjobs.push(subjob)
      logger.debug "Added subjob: #{subjob.name}"
    end
    
    logger.debug "Trying to handle successors"
    @successors = subjob.constraints_as_subjob_one
    logger.debug "# of successors: #{@successors.size}"
    unless @successors.blank?
      @successors.each do |constraint|
        logger.debug "Current subjob: #{subjob.name}"
        if(constraint.subjob_two)
          logger.debug "Successor: #{constraint.subjob_two.name}"
          unless exclude.include?(subjob) #(exclude.any?{|entry| entry.id == subjob.id})
            #Constraint f√ºhrt zu weiterem Subjob (weiter nach Schliefen suchen), ausser Subjob wurde bereits fr√ºher gepr√ºft (exclude)
            logger.debug "Branch: Subjob #{subjob.name} got not tested, search further in successor #{constraint.subjob_two.name}"
            @check = search_cycles(constraint.subjob_two, subjobs, exclude)
            unless @check
              return @check
            end
            logger.debug "Merge: Finished searching cycles from #{subjob.name} within successor #{constraint.subjob_two.name}"
            logger.debug " "
          end
        end
      end
    else
        #Constraint f¸hrt zum Ende (keine Schleife)
        logger.debug "No cycle, returning found subjobs"
        return subjobs
    end
    logger.debug "No further successors, returning subjobs"
    logger.debug "Number of subjobs: #{subjobs.size}"
    logger.debug " "
    return subjobs
  end
end
