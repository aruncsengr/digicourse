require 'rails_helper'

RSpec.describe 'Api::V1::courses', type: :request do
  describe "POST /create" do
    context 'when the request is valid' do
      let(:valid_payload) do
        {
          course: {
            title: 'Ruby',
            description: 'Dev friendly language.',
            tutors_attributes: [{
              "first_name"=>"Royce",
              "last_name"=>"Gottlieb",
              "email"=>"sydney.lueilwitz@example.com"
            }]
          }
        }
      end

      it 'returns status code 201' do
        post '/api/v1/courses', params: valid_payload
        expect(response).to have_http_status(:created)
      end

      it 'creates a course with its tutors' do
        expect(Course.count).to eq 0
        expect(Tutor.count).to eq 0

        post '/api/v1/courses', params: valid_payload

        expect(Course.count).to eq 1
        expect(Tutor.count).to eq 1
      end
    end

    context 'when the request is invalid' do
      context 'when course title is blank' do
        let(:invalid_payload) do
          {
            course: { title: '' }
          }
        end

        before { post '/api/v1/courses', params: invalid_payload }

        it 'returns status code 422' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it 'returns a validation failure error details' do
          error = parse_json['errors'].first
          expect(error['source']['pointer']).to eq "/data/attributes/title"
          expect(error['detail']).to eq "can't be blank"
        end

        it "does not create a new course" do
          expect {
            post '/api/v1/courses', params: invalid_payload, as: :json
          }.to change(Course, :count).by(0)
        end
      end

      context 'when course title is duplicate' do
        let(:payload) do
          {
            course: { title: 'duplicate title' }
          }
        end

        before do
          create(:course, title: 'duplicate title')
        end

        it 'returns status code 422' do
          post '/api/v1/courses', params: payload

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
        end

        it 'returns a validation failure error details' do
          post '/api/v1/courses', params: payload

          error = parse_json['errors'].first
          expect(error['source']['pointer']).to eq "/data/attributes/title"
          expect(error['detail']).to eq "has already been taken"
        end

        it "does not create a new course" do
          expect {
            post '/api/v1/courses', params: payload, as: :json
          }.to change(Course, :count).by(0)
        end
      end

      context 'when tutors payload data is invalid' do
        context 'when email is blank' do
          let(:invalid_tutor_payload) do
            {
              course: {
                title: 'Ruby',
                description: 'Dev friendly language.',
                tutors_attributes: [{
                  "first_name"=>"",
                  "last_name"=>"Gottlieb",
                  "email"=>""
                }]
              }
            }
          end

          it 'returns status code 422' do
            post '/api/v1/courses', params: invalid_tutor_payload

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to match(a_string_including("application/json"))
          end

          it 'returns a validation failure error details' do
            post '/api/v1/courses', params: invalid_tutor_payload
            expect(parse_json['errors']).to match_array(
              [
                {"source"=>{"pointer"=>"/data/attributes/tutors.first-name"}, "detail"=>"can't be blank"},
                {"source"=>{"pointer"=>"/data/attributes/tutors.email"}, "detail"=>"can't be blank"}
              ]
            )
          end

          it "does not create a course with tutor" do
            expect(Course.count).to eq 0
            expect(Tutor.count).to eq 0

            post '/api/v1/courses', params: invalid_tutor_payload

            expect(Course.count).to eq 0
            expect(Tutor.count).to eq 0
          end
        end
      end
    end
  end

  describe "GET /index" do
    let(:course_1) { create(:course) }
    let(:course_2) { create(:course) }

    let!(:tutor_1) { create(:tutor, course: course_1)}
    let!(:tutor_2) { create(:tutor, course: course_1)}
    let!(:tutor_3) { create(:tutor, course: course_2)}
    let!(:tutor_4) { create(:tutor, course: course_2)}

    # Note:
    # JSON:API - a specification for building APIs in JSON
    # ref: https://jsonapi.org/
    let(:expected_response) do
      {
        "data"=>[
          {
            "id"=>course_1.id.to_s,
            "type"=>"courses",
            "attributes"=>{
              "title"=>course_1.title,
              "description"=>course_1.description
            },
            "relationships"=>{
              "tutors"=>{
                "data"=>[
                  {"id"=>tutor_1.id.to_s, "type"=>"tutors"},
                  {"id"=>tutor_2.id.to_s, "type"=>"tutors"}
                ]
              }
            }
          },
          {
            "id"=>course_2.id.to_s,
            "type"=>"courses",
            "attributes"=>{
              "title"=>course_2.title,
              "description"=>course_2.description
            },
            "relationships"=>{
              "tutors"=>{
                "data"=>[
                  {"id"=>tutor_3.id.to_s, "type"=>"tutors"},
                  {"id"=>tutor_4.id.to_s, "type"=>"tutors"}
                ]
              }
            }
          }
        ],
        "included"=>[
          {
            "id"=>tutor_1.id.to_s,
            "type"=>"tutors",
            "attributes"=>{
              "first-name"=>tutor_1.first_name, "last-name"=>tutor_1.last_name, "email"=>tutor_1.email
            },
            "relationships"=>{
              "course"=>{"data"=>{"id"=>course_1.id.to_s, "type"=>"courses"}}
            }
          },
          {
            "id"=>tutor_2.id.to_s,
            "type"=>"tutors",
            "attributes"=>{
              "first-name"=>tutor_2.first_name, "last-name"=>tutor_2.last_name, "email"=>tutor_2.email
            },
            "relationships"=>{
              "course"=>{"data"=>{"id"=>course_1.id.to_s, "type"=>"courses"}}
            }
          },
          {
            "id"=>tutor_3.id.to_s,
            "type"=>"tutors",
            "attributes"=>{
              "first-name"=>tutor_3.first_name, "last-name"=>tutor_3.last_name, "email"=>tutor_3.email
            },
            "relationships"=>{
              "course"=>{"data"=>{"id"=>course_2.id.to_s, "type"=>"courses"}}
            }
          },
          {
            "id"=>tutor_4.id.to_s,
            "type"=>"tutors",
            "attributes"=>{
              "first-name"=>tutor_4.first_name, "last-name"=>tutor_4.last_name, "email"=>tutor_4.email
            },
            "relationships"=>{
              "course"=>{"data"=>{"id"=>course_2.id.to_s, "type"=>"courses"}}
            }
          },
        ],
        "links"=>{
          "self"=>"http://www.example.com/api/v1/courses?page%5Bnumber%5D=1&page%5Bsize%5D=30",
          "first"=>"http://www.example.com/api/v1/courses?page%5Bnumber%5D=1&page%5Bsize%5D=30",
          "prev"=>nil,
          "next"=>nil,
          "last"=>"http://www.example.com/api/v1/courses?page%5Bnumber%5D=1&page%5Bsize%5D=30"
        }
      }
    end

    it 'returns status code 200' do
      get '/api/v1/courses', as: :json

      expect(response).to have_http_status(:successful)
      expect(response.content_type).to match(a_string_including("application/json"))
    end

    it "renders a successful response of course with tutors" do
      get '/api/v1/courses', as: :json

      expect(parse_json).to eq expected_response
      expect(response).to be_successful
    end

    context 'pagination' do
      context 'when page params are valid' do
        it 'returns status code 200' do
          get api_v1_courses_url(page: { number: 1, size: 1 }), as: :json

          expect(response).to have_http_status(:successful)
          expect(parse_json['links']).to be_present
        end
      end

      context 'when page number is invalid' do
        it 'returns status code 400' do
          get api_v1_courses_url(page: { number: 'invalid', size: 1 }), as: :json

          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
