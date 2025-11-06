require 'swagger_helper'

RSpec.describe 'Companies API', type: :request do
  path '/api/v1/companies' do

    get 'List Companies' do
      tags 'Companies'
      produces 'application/json'

      response '200', 'companies found' do
        run_test!
      end
    end

    post 'Create Company' do
      tags 'Companies'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string }
            },
            required: ['name', 'description']
          }
        },
        required: ['company']
      }

      response '201', 'company created' do
        let(:user) { User.create!(email: 'thiago@test.com', password: '123456') }
        let(:Authorization) { "Bearer #{user.generate_jwt}" }
        let(:company) { { company: { name: 'Book Store', description: 'Great books!' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:company) { { company: { name: '' } } }
        run_test!
      end
    end
  end
end
