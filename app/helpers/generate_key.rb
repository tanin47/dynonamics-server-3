module GenerateKey
    
    def generate_unique_key
      if self.dynonamics_key != nil
        return
      end
      
      srand(Time.now.to_i + 1)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'

      token = ""
      success = false
      while !success 
        
        token = ''
        10.times { token << chars[rand(chars.size)] }

        if !self.class.first(:conditions=>{:dynonamics_key=>token})
          break;
        end
      end

      self.dynonamics_key = token
    end
end