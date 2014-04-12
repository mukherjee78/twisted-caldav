module Net
    class HTTP
        class Report < HTTPRequest
            METHOD = 'REPORT'
            REQUEST_HAS_BODY = true
            RESPONSE_HAS_BODY = true
        end

        class Mkcalendar < HTTPRequest
            METHOD = 'MKCALENDAR'
            REQUEST_HAS_BODY = true
            RESPONSE_HAS_BODY = true
        end
    end
end

