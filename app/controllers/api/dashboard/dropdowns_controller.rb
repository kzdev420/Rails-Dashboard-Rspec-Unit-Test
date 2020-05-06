module Api
  module Dashboard
    class DropdownsController < ApplicationController

      api :GET, '/api/dashboard/dropdowns/manufacturers_list', 'Get manufacturers list'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/agency_officers_list', 'Officer list on an agency'
      param :agency_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/categories_place', 'Load categories list for nearby locations/places'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/categories_place', 'Load categories list for nearby locations/places'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/country_code', 'Load countries list'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/parking_lot_parking_admins_filter', 'Load parking admins list that an admin can see'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/parking_lot_town_managers_filter', 'Load town managers list that an admin can see'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/parking_session_kiosk_ids_list', 'Load kiosk IDs used on a parking lot'
      param :parking_lot_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/parking_session_statuses_list', 'Get all possible statuses that a parking session can have'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/payment_methods_list', 'Get a list of all possible payment methods'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/role_id', 'Get a list of all roles that a user can create'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/role_names_filter', 'Get a list of all roles'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/tickets_agencies_list', 'Get a list of all agencies that an admin can see, associated to a list of tickets'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/tickets_officers_filter', 'Get a list of all officers that an admin can see, associated to a list of tickets'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/tickets_statuses_field', 'Get a list of all statuses on the tickets'
      param :admin_id, Integer, required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/tickets_types_field', 'Get a list of all rules'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/admins_by_role/manager', 'Get a list of all managers'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/admins_by_role/officer', 'Get a list of all officer'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/admins_by_role/parking_admin', 'Get a list of all parking admins'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/dashboard/dropdowns/admins_by_role/town_manager', 'Get a list of all town managers'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        dropdown_field = "dropdown_fields/dashboard/#{params[:id].gsub('-','/')}".classify.constantize.new(params)
        respond_with dropdown_field.search
      end

    end
  end
end
