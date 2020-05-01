class Contact < ApplicationRecord
		belongs_to :kind
		
		# def kind_description
		# 	self.kind.description
		# end

    # def as_json(options = {})
    #     super(
		# 			methods: [:kind_description],
		# 			include: {kind: {only: :description}}
    #     )
    # end
end