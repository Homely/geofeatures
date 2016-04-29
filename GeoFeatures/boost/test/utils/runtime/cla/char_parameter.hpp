//  (C) Copyright Gennadiy Rozental 2005-2014.
//  Use, modification, and distribution are subject to the
//  Boost Software License, Version 1.0. (See accompanying file
//  LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

//  See http://www.boost.org/libs/test for the library home page.
//
//  File        : $RCSfile$
//
//  Version     : $Revision$
//
//  Description : defines model of parameter with single char name
// ***************************************************************************

#ifndef BOOST_TEST_UTILS_RUNTIME_CLA_CHAR_PARAMETER_HPP
#define BOOST_TEST_UTILS_RUNTIME_CLA_CHAR_PARAMETER_HPP

// Boost.Runtime.Parameter
#include <boost/test/utils/runtime/config.hpp>
#include <boost/test/utils/runtime/validation.hpp>

#include <boost/test/utils/runtime/cla/basic_parameter.hpp>
#include <boost/test/utils/runtime/cla/id_policy.hpp>

namespace geofeatures_boost {} namespace boost = geofeatures_boost; namespace geofeatures_boost {

namespace BOOST_TEST_UTILS_RUNTIME_PARAM_NAMESPACE {

namespace cla {

// ************************************************************************** //
// **************               char_name_policy               ************** //
// ************************************************************************** //

class char_name_policy : public basic_naming_policy {
public:
    // Constructor
    char_name_policy();
    BOOST_TEST_UTILS_RUNTIME_PARAM_UNNEEDED_VIRTUAL ~char_name_policy() {}

    // policy interface
    virtual bool    conflict_with( identification_policy const& ) const;

    // Accept modifier
    template<typename Modifier>
    void            accept_modifier( Modifier const& m )
    {
        basic_naming_policy::accept_modifier( m );

        BOOST_TEST_UTILS_RUNTIME_PARAM_VALIDATE_LOGIC( p_name->size() <= 1, "Invalid parameter name "  << p_name );
    }
};

// ************************************************************************** //
// **************          runtime::cla::char_parameter        ************** //
// ************************************************************************** //

template<typename T>
class char_parameter_t : public basic_parameter<T,char_name_policy> {
    typedef basic_parameter<T,char_name_policy> base;
public:
    // Constructors
    explicit    char_parameter_t( char_type name ) : base( cstring( &name, 1 ) ) {}
};

//____________________________________________________________________________//

template<typename T>
inline shared_ptr<char_parameter_t<T> >
char_parameter( char_type name )
{
    return shared_ptr<char_parameter_t<T> >( new char_parameter_t<T>( name ) );
}

//____________________________________________________________________________//

inline shared_ptr<char_parameter_t<cstring> >
char_parameter( char_type name )
{
    return shared_ptr<char_parameter_t<cstring> >( new char_parameter_t<cstring>( name ) );
}

//____________________________________________________________________________//

} // namespace cla

} // namespace BOOST_TEST_UTILS_RUNTIME_PARAM_NAMESPACE

} // namespace geofeatures_boost

#ifndef BOOST_TEST_UTILS_RUNTIME_PARAM_OFFLINE

#ifndef BOOST_TEST_UTILS_RUNTIME_PARAM_INLINE
#   define BOOST_TEST_UTILS_RUNTIME_PARAM_INLINE inline
#endif
#   include <boost/test/utils/runtime/cla/char_parameter.ipp>

#endif

#endif // BOOST_TEST_UTILS_RUNTIME_CLA_CHAR_PARAMETER_HPP