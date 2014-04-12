require 'spec_helper'
require 'pact/configuration'

describe Pact do

  before do
    Pact.clear_configuration
  end

  describe "configure" do
    KEY_VALUE_PAIRS = {pact_dir: 'a path', log_dir: 'a dir', logger: 'a logger'}

    KEY_VALUE_PAIRS.each do | key, value |
      it "should allow configuration of #{key}" do
        Pact.configure do | config |
          config.send("#{key}=".to_sym, value)
        end

        expect(Pact.configuration.send(key)).to eql(value)
      end
    end

  end

  describe Pact::Configuration do
    let(:configuration) { Pact::Configuration.new }

    describe "doc_generator" do

      context "with a symbol" do
        it "allows configuration of a doc_generator" do
          Pact.configuration.doc_generator = :markdown
          expect(Pact.configuration.doc_generators).to eq [Pact::Doc::Markdown::Generator]
        end
      end

      context "with anything that responds to 'call'" do

        it "allows configuration of a doc_generator" do
          Pact.configuration.doc_generator = lambda { | pact_dir, doc_dir | "doc" }
          expect(Pact.configuration.doc_generators.size).to be 1
          expect(Pact.configuration.doc_generators.first.call('doc','pacts')).to eq ("doc")
        end

      end

      context "with something that does not respond to call and doesn't have a matching doc_generator" do
        it "raises an error" do
          expect { Pact.configuration.doc_generator = Object.new }.to raise_error "Pact.configuration.doc_generator needs to respond to call, or be in the preconfigured list: [:markdown]"
        end
      end

    end

    describe "pactfile_write_mode" do
      context "when @pactfile_write_mode is :overwrite" do
        it 'returns :overwrite' do
          configuration.pactfile_write_mode = :overwrite
          expect(configuration.pactfile_write_mode).to eq :overwrite
        end
      end
      context "when @pactfile_write_mode is :update" do
        it 'returns :overwrite' do
          configuration.pactfile_write_mode = :update
          expect(configuration.pactfile_write_mode).to eq :update
        end
      end
      context "when @pactfile_write_mode is :smart" do
        before do
          configuration.pactfile_write_mode = :smart
          configuration.should_receive(:is_rake_running?).and_return(is_rake_running)
        end
        context "when rake is running" do
          let(:is_rake_running) { true }
          it "returns :overwrite" do
            expect(configuration.pactfile_write_mode).to eq :overwrite
          end
        end
        context "when rake is not running" do
          let(:is_rake_running) { false }
          it "returns :update" do
            expect(configuration.pactfile_write_mode).to eq :update
          end
        end
      end
    end
  end
    describe "default_configuration" do
      it "should have a default pact_dir" do
        expect(Pact.configuration.pact_dir).to eql File.expand_path('./spec/pacts')
      end
      it "should have a default log_dir" do
        expect(Pact.configuration.log_dir).to eql File.expand_path('./log')
      end
      it "should have a default logger configured" do
        expect(Pact.configuration.logger).to be_instance_of Logger
      end
    end

end