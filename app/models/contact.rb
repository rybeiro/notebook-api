class Contact < ApplicationRecord
		belongs_to :kind
		has_many :phones

		def as_json(options={})
			h = super(options)
			h[:birthday] = (I18n.l(self.birthday) unless self.birthday.blank?)
			h
		end
		
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